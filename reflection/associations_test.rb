# frozen_string_literal: true

require 'test_helper'

# Make sure every ActiveRecord class is loaded so that the call to ::descendants
# works as expected.
Rails.application.eager_load!

class AssociationsTest < ActiveSupport::TestCase
  class ReflectionChecks < SimpleDelegator
    def check_foreign_key?
      macro == :belongs_to || !options[:through]
    end

    def check_foreign_type?
      options[:polymorphic]
    end

    def check_inverse?
      !options[:polymorphic] && !options[:through]
    end

    def column_class
      macro == :belongs_to ? active_record : klass
    end

    def descriptor
      "#{active_record.name} #{macro} :#{name}"
    end
  end

  ApplicationRecord.descendants.each do |clazz|
    clazz.reflect_on_all_associations.each do |reflection|
      test "#{clazz.name} #{reflection.macro} #{reflection.name} association" do
        reflection.check_validity!
        assert_valid_association ReflectionChecks.new(reflection)
      end
    end
  end

  private

  def assert_valid_association(reflection)
    assert_valid_method reflection

    if reflection.check_foreign_key?
      assert_column_name reflection.column_class, reflection.foreign_key
    end

    if reflection.check_foreign_type?
      assert_column_name reflection.active_record, reflection.foreign_type
    end

    if reflection.check_inverse? && Rails::VERSION::MAJOR >= 6
      assert_valid_inverse reflection
    end
  end

  def assert_column_name(clazz, column_name)
    assert_includes clazz.column_names, column_name.to_s,
                    "Expected #{clazz.name} to have the column name " \
                    "\"#{column_name}\""
  end

  def assert_valid_method(reflection)
    reflection.active_record.new.public_send(reflection.name)
  rescue StandardError
    flunk "Expected #{reflection.active_record.name} to have a valid " \
          "##{reflection.name} method"
  end

  def assert_valid_inverse(reflection)
    assert reflection.has_inverse?, "Excepted #{reflection.descriptor} to " \
                                    'have an inverse association'
    reflection.check_validity_of_inverse!
  end
end
