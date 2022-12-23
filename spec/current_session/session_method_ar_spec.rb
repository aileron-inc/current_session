# frozen_string_literal: true

require "spec_helper"

create_tables = Class.new(ActiveRecord::Migration[7.0]) do
  def self.create_table_users
    create_table(:users) do |t|
      t.string "uid", null: false
      t.string "name"
      t.json "auth"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["uid"], name: "index_users_on_uid", unique: true
    end
  end

  def self.create_table_session_tokens
    create_table(:user_session_tokens) do |t|
      t.string "value", null: false
      t.string "user_id", null: false
      t.string "last_request_at"
      t.string "last_request_ip"
      t.string "last_request_user_agent"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
  end

  def self.up
    create_table_users
    create_table_session_tokens
  end

  def self.down
    drop_table(:users)
    drop_table(:user_session_tokens)
  end
end

RSpec.describe CurrentSession::SessionMethod do
  describe "ActiveRecord" do
    around(:context) do |example|
      create_tables.up
      example.run
      create_tables.down
    end

    before do
      stub_const "User::Session", example_session_class
      stub_const "User", (Class.new(ActiveRecord::Base) do
        has_many :session_tokens, class_name: "UserSessionToken"
      end)
      stub_const "UserSessionToken", (Class.new(ActiveRecord::Base) do
        before_save(unless: :value?) { self.value = SecureRandom.urlsafe_base64(64) }
        belongs_to :user
      end)
    end

    let(:example_session_class) do
      Class.new(CurrentSession::Base) do
        def self.name
          "User::Session"
        end

        session_methods do
          def find
            token = UserSessionToken.find_by(value: request.session["session_token"])
            token&.update(
              last_request_at: Time.current,
              last_request_ip: request.remote_ip,
              last_request_user_agent: request.user_agent
            )
            token&.user
          end

          def create(user)
            UserSessionToken.create(user_id: user.id, value: new_session_token) do |record|
              record.attributes = {
                last_request_at: Time.current,
                last_request_ip: request.remote_ip,
                last_request_user_agent: request.user_agent
              }
              request.session["session_token"] = record.value
            end
          end

          def destroy
            UserSessionToken.find_by(value: request.session["session_token"])&.destroy
            request.session.delete("session_token")
          end
        end
        auth_methods do
          def connect
            user = User.find_or_initialize_by(uid: auth[:uid])
            user.update(
              name: auth[:info][:name],
              auth: auth
            )
            user
          end
        end

        def self.name
          "UserSession"
        end
      end
    end

    let(:uid) { SecureRandom.uuid }
    let(:omniauth_auth) do
      OmniAuth::AuthHash.new(
        provider: "twitter",
        uid: uid,
        info: {
          name: "test"
        },
        credentials: {}
      )
    end

    describe "#create" do
      let(:request) do
        MockHttpRequest.new(
          env: { "omniauth.auth" => omniauth_auth },
          session: {},
          remote_ip: "127.0.0.1",
          user_agent: "test user-agent"
        )
      end

      specify do
        expect { example_session_class.create(request) }.to \
          change { User.pick(:uid) }.to(uid) &
          change(User, :count).by(+1) &
          change { UserSessionToken.find_by(value: request.session["session_token"]).present? }.from(false).to(true)
      end
    end

    describe "#update" do
      let(:current_session_token) { UserSessionToken.create(user_id: current_user.id).value }
      let!(:current_user) { User.create(uid: uid, name: "test") }
      let!(:request) do
        MockHttpRequest.new(
          session: { "session_token" => current_session_token },
          remote_ip: "127.0.0.1",
          user_agent: "test user-agent"
        )
      end

      specify do
        expect(example_session_class.update(request).current_user).to eq(current_user)
        expect(example_session_class.call(request)).to be(true)
      end
    end

    describe "#destroy" do
      let(:current_session_token) { UserSessionToken.create(user: User.create(uid: uid, name: "test")).value }
      let!(:request) do
        MockHttpRequest.new(
          session: { "session_token" => current_session_token },
          remote_ip: "127.0.0.1",
          user_agent: "test user-agent"
        )
      end

      specify do
        expect { example_session_class.destroy(request) }.to change(UserSessionToken, :count).by(-1)
        expect(example_session_class.update(request).current_user).to be_nil
      end
    end
  end
end
