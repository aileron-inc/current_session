# frozen_string_literal: true

module CurrentSession
  #
  # Base class for implementing current_user
  #
  class Base < ActiveSupport::CurrentAttributes
    include CurrentSession::Interface
    include CurrentSession::Dsl
    attribute :current_user
  end
end
