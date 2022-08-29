# frozen_string_literal: true

ActiveRecord::Base.configurations = { "test" => { adapter: "sqlite3", database: ":memory:" } }
ActiveRecord::Base.establish_connection :test
ActiveRecord::Migration.verbose = false
