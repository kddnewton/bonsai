require 'test_helper'

class DefTest < ActiveSupport::TestCase
  LEGACY = File.readlines('legacy.txt').map(&:chomp).freeze

  test 'no more defs in models' do
    def_list = DefList.from(Dir['app/models/*.rb'])
    violations = def_list.defs.map(&:to_s) - LEGACY

    assert_empty violations, <<~MSG
      Expected #{methods} to be empty. It looks like you defined an instance
      method on an ActiveRecord model. We prefer to leave AR model declarations
      to contain only database-level logic (like scopes and associations) and to
      instead place other logic in delegated objects. Check out `Ext::Factory`
      and `Ext::Query` for examples.
    MSG
  end
end
