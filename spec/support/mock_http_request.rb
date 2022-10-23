# frozen_string_literal: true

MockHttpRequest = Struct.new(:env, :session, :remote_ip, :user_agent, keyword_init: true)
