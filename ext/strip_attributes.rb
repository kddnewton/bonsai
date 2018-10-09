# frozen_string_literal: true

module Ext
  # In some ActiveRecord models we want to automatically strip the value of
  # surrounding whitespace before it's saved to the database. You would
  # normally accomplish this using a `before_validation` callback, as in:
  #
  #     before_validation do
  #       self.name = name.strip
  #       self.title = title.strip
  #     end
  #
  # This same method can be accomplished by using this module by doing:
  #
  #     include Ext::StripAttributes.new(:name, :title)
  #
  class StripAttributes < Module
    def initialize(*attributes)
      define_strip_attributes_for(attributes)
    end

    def included(base)
      base.before_validation(:strip_attributes)
    end

    private

    def define_strip_attributes_for(attributes)
      define_method(:strip_attributes) do
        attributes.each do |attribute|
          value = public_send(attribute)
          public_send(:"#{attribute}=", value.strip) if value
        end
      end
    end
  end
end
