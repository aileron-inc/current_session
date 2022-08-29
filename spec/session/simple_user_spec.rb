# frozen_string_literal: true

require "spec_helper"

create_tables = Class.new(ActiveRecord::Migration[7.0]) do
  def self.create_table_users
    create_table(:simple_users) do |t|
      t.string "uid", null: false
      t.string "name"
      t.string "session_token"
      t.string "last_request_at"
      t.string "last_request_ip"
      t.string "last_request_user_agent"
      t.index ["uid"], name: "index_users_on_uid", unique: true
      t.index ["session_token"], name: "index_users_on_session_token", unique: true
    end
  end

  def self.up
    create_table_users
  end

  def self.down
    drop_table(:simple_users)
  end
end

RSpec.describe CurrentSession do
  before(:all) { create_tables.up }
  after(:all) { create_tables.down }
  before do
    stub_const "User", (Class.new(ActiveRecord::Base) do
      self.table_name = "simple_users"
    end)
  end
  let(:user_class) { User }
  let(:session_key) { CurrentSession.key(User) }

  let(:example_session_class) do
    Class.new(CurrentSession::Base) do
      self.user_class = User
      auth_methods do
        def find_or_create_by_auth
          user_class.find_or_create_by(uid: auth[:uid])
        end

        def update(user)
          user.update(
            name: auth[:info][:name]
          )
        end
      end
      session_methods do
        def find
          user_class.find_by(session_token: session_token).try do |user|
            user.update(
              last_request_at: current_time,
              last_request_ip: request.remote_ip,
              last_request_user_agent: request.user_agent
            )
            yield user
          end
        end

        def create(user)
          user.update(
            session_token: new_session_token,
            last_request_at: current_time,
            last_request_ip: request.remote_ip,
            last_request_user_agent: request.user_agent
          )
          user.session_token
        end

        def destroy
          user_class.find_by(session_token: session_token)&.update(session_token: nil)
        end
      end

      def self.name
        "SimpleSession"
      end
    end
  end

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

  let(:uid) { SecureRandom.urlsafe_base64(64) }

  describe "#create" do
    let(:request) do
      double(
        "HttpRequest",
        env: { "omniauth.auth" => omniauth_auth },
        session: {},
        remote_ip: "127.0.0.1",
        user_agent: "test user-agent"
      )
    end
    specify do
      expect { example_session_class.create(request) }.to \
        change { User.pick(:uid) }.to(uid) &
        change { User.count }.by(+1) &
        change { request.session[session_key].present? }.from(false).to(true)
    end
  end

  describe "#update" do
    let(:current_session_token) { "testtest" }
    let!(:current_user) { user_class.create(uid: uid, name: "test", session_token: current_session_token) }
    let!(:request) do
      double(
        "HttpRequest",
        session: { session_key => current_session_token },
        remote_ip: "127.0.0.1",
        user_agent: "test user-agent"
      )
    end
    specify do
      expect(example_session_class.update(request).current_user).to eq(current_user)
      expect(example_session_class.call(request)).to eq(true)
    end
  end

  describe "#destroy" do
    let(:current_session_token) { "destroy-test" }
    let!(:current_user) { user_class.create(uid: uid, name: "test", session_token: current_session_token) }
    let!(:request) do
      double(
        "HttpRequest",
        session: { session_key => current_session_token },
        remote_ip: "127.0.0.1",
        user_agent: "test user-agent"
      )
    end
    specify do
      expect { example_session_class.destroy(request) }.to change { current_user.reload.session_token } \
        .from(current_session_token).to(nil)
      expect(example_session_class.update(request).current_user).to be_nil
    end
  end
end
