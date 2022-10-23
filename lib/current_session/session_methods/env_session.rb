# frozen_string_literal: true

module CurrentSession
  module SessionMethods
    #
    # repository to return the user specified by the environment variable
    #
    module EnvSession
      # rubocop:disable Metrics/MethodLength
      def self.build(current_user_id)
        Module.new do
          define_method(:current_user) { user_class.find(current_user_id) }

          def try_session_token
            yield self
          end

          def find
            yield current_user
          end

          def create(_)
          end

          def destroy
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
