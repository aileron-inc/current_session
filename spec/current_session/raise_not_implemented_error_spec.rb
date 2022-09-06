# frozen_string_literal: true

require "spec_helper"

RSpec.describe CurrentSession::RaiseNotImplementedError do
  before do
    stub_const "User", Class.new(ActiveRecord::Base)
  end

  let(:user_class) { User }
  let(:not_implemented_session_methods) do
    {
      class: Class.new(CurrentSession::Base) do
               self.user_class = user_class
             end,

      find: Class.new(CurrentSession::Base) do
        self.user_class = user_class
        session_methods do
          def create
          end

          def destroy
          end
        end
      end,

      destroy: Class.new(CurrentSession::Base) do
        self.user_class = user_class
        session_methods do
          def find
          end

          def create
          end
        end
      end,

      create: Class.new(CurrentSession::Base) do
                self.user_class = user_class
                session_methods do
                  def find
                  end

                  def destroy
                  end
                end
              end
    }
  end

  let(:not_implemented_auth_class) do
    {
      class:
    Class.new(CurrentSession::Base) do
      self.user_class = user_class
      self.session_methods = CurrentSession::ActiveRecordSession
    end,

      find_or_create_by_auth:
    Class.new(CurrentSession::Base) do
      self.user_class = user_class
      self.session_methods = CurrentSession::ActiveRecordSession
      auth_methods do
      end
    end,

      update:
    Class.new(CurrentSession::Base) do
      self.user_class = user_class
      self.session_methods = CurrentSession::ActiveRecordSession
      auth_methods do
        def find_or_create_by_auth
        end
      end
    end

    }
  end

  {
    class: /setting self.session_repository/,
    find: /find/,
    destroy: /destroy/,
    create: /create/
  }.each do |name, expected|
    describe "CurrentSession::Repository##{name}" do
      specify do
        expect { not_implemented_session_methods[name].raise_not_implemented_error }.to raise_error do |error|
          expect(error).to be_a(NotImplementedError)
          expect(error.message).to match(expected)
        end
      end
    end
  end

  {
    class: /setting self.auth/,
    find_or_create_by_auth: /find_or_create_by_auth/,
    update: /update/
  }.each do |name, expected|
    describe "CurrentSession::Auth##{name}" do
      specify do
        expect { not_implemented_auth_class[name].raise_not_implemented_error }.to raise_error do |error|
          expect(error).to be_a(NotImplementedError)
          expect(error.message).to match(expected)
        end
      end
    end
  end
end
