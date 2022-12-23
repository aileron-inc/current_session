# frozen_string_literal: true

require "spec_helper"

create_tables = Class.new(ActiveRecord::Migration[7.0]) do
  def self.create_table_users
    create_table(:env_users) do |t|
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
    drop_table(:env_users)
  end
end

RSpec.describe CurrentSession::SessionMethod do
  describe "ENV['CURRENT_USER_ID']" do
    around(:context) do |example|
      create_tables.up
      example.run
      create_tables.down
    end

    before do
      stub_const "EnvUser::Session", example_session_class
      stub_const "EnvUser", (Class.new(ActiveRecord::Base) do
      end)
    end

    let!(:user_class) { EnvUser }
    let(:example_session_class) do
      Class.new(CurrentSession::Base) do
        self.session_methods = CurrentSession::SessionMethod.define { EnvUser.find_by(uid: "test") }

        def self.name
          "EnvUser::Session"
        end
      end
    end

    describe "#update" do
      let!(:current_user) { user_class.create(uid: "test", name: "test") }
      let(:request) do
        MockHttpRequest.new(
          remote_ip: "127.0.0.1",
          user_agent: "test user-agent",
          session: {}
        )
      end

      specify do
        expect(example_session_class.update(request).current_user).to eq(current_user)
      end
    end
  end
end
