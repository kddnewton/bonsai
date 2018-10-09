# frozen_string_literal: true

require 'test_helper'

class UpgradeTest < ActiveSupport::TestCase
  LAST_TESTED_VERSION = Gem::Version.new('5.2.1')

  def self.test(name)
    version = Gem::Version.new(Rails::VERSION::STRING)

    super(name) { flunk if version > LAST_TESTED_VERSION }
  end

  test 'Comment#as_json'
  test 'counter_cache and touch on comment'
  test 'counter_cache and touch on cheer'
  test 'ApplicationController::make_response!'
  test 'Buildable::TouchAll'
end
