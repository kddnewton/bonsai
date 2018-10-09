# frozen_string_literal: true

require 'test_helper'

# Make sure every ActionController class is loaded so that the call to
# ::descendants works as expected.
Rails.application.eager_load!

class ControllerActionsTest < ActiveSupport::TestCase
  ALLOWED = %w[index show create update destroy].freeze

  ApplicationController.descendants.each do |controller|
    test "#{controller.name} only has standard actions" do
      violations = controller.action_methods - ALLOWED

      assert_empty violations,
    end
  end
end
