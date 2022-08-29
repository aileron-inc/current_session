# frozen_string_literal: true

require "spec_helper"

create_tables = Class.new(ActiveRecord::Migration[7.0]) do
  def self.create_table_users
    create_table(:uid_session_users) do |t|
      t.string "uid", null: false
      t.string "name"
      t.json "omniauth"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["uid"], name: "index_users_on_uid", unique: true
    end
  end

  def self.up
    create_table_users
  end

  def self.down
    drop_table(:uid_session_users)
  end
end

RSpec.describe CurrentSession::EnvSession do
  before do
    stub_const "User", (Class.new(ActiveRecord::Base) do
      self.table_name = "uid_session_users"
    end)
  end
  let(:user_class) { User }
  before(:all) { create_tables.up }
  after(:all) { create_tables.down }

  let(:session_key) { CurrentSession.key(User) }
  let(:example_session_class) do
    Class.new(CurrentSession::Base) do
      self.user_class = User
      self.session_repository_class = CurrentSession::UidSession
      auth_methods do
        def find_or_create_by_auth
          user_class.find_or_create_by(uid: auth[:uid]) do |instance|
            instance.name = auth[:info][:name]
          end
        end

        def update(user)
          user.update(
            name: auth[:info][:name],
            omniauth: auth
          )
        end
      end

      def self.name
        "User::Session"
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
        change { request.session[session_key].present? }.from(false).to(true) &
        change { request.session[session_key] == uid }.from(false).to(true)
    end
  end

  describe "#update" do
    let!(:current_user) { user_class.create(uid: "test", name: "test") }
    let(:request) do
      double(
        "HttpRequest",
        remote_ip: "127.0.0.1",
        user_agent: "test user-agent",
        session: { session_key => "test" }
      )
    end
    specify do
      expect(example_session_class.update(request).current_user).to eq(current_user)
    end
  end

  describe "#destroy" do
    let(:uid) { "destory-uid-test" }
    let(:current_user) { user_class.create(uid: uid, name: "test") }
    let!(:request) do
      double(
        "HttpRequest",
        session: { session_key => uid },
        remote_ip: "127.0.0.1",
        user_agent: "test user-agent"
      )
    end
    specify do
      expect { example_session_class.destroy(request) }.to change { request.session[session_key] }.from(uid).to(nil)
      expect(example_session_class.update(request).current_user).to be_nil
    end
  end
end
