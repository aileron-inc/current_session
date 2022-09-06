# frozen_string_literal: true

require "spec_helper"

RSpec.describe CurrentSession do
  it "has a version number" do
    expect(CurrentSession::VERSION).not_to be_nil
  end
end
