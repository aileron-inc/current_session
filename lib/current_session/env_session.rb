# frozen_string_literal: true

module CurrentSession
  #
  # repository to return the user specified by the environment variable
  #
  class EnvSession < Repository
    # rubocop:disable Metrics/MethodLength
    def self.build(current_user_id)
      Class.new(Repository) do
        define_method(:current_user) { user_class.find(current_user_id) }

        def try
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
