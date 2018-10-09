# frozen_string_literal: true

module Ext
  # A lot of the time related functionality can be extracted into separate
  # objects. For example, in the following code there are a lot of methods that
  # have to do with the two name fields:
  #
  #     class User
  #       attr_reader :first_name, :last_name
  #
  #       def initials
  #         "#{first_name[0]}#{last_name[0]}"
  #         first_name[0]
  #       end
  #
  #       def full_name
  #         "#{first_name} #{last_name}"
  #       end
  #     end
  #
  # In this case, we could extract an object that knows how to get these names
  # together. That would look like:
  #
  #     class User
  #       class Name < Struct.new(:user)
  #         ...
  #       end
  #
  #       def name
  #         @name ||= Name.new(self)
  #       end
  #
  #       delegate :initials, :full_name, to: :name
  #     end
  #
  # This is common enough that you can use this module to accomplish the same
  # thing, as in:
  #
  #     class User
  #       factory :name, Name, delegate: %i[initials full_name]
  #     end
  #
  module Factory
    def factory(method_name, clazz, delegate: [])
      define_method(method_name) { clazz.new(self) }

      return if Array(delegate).empty?

      public_send(:delegate, *delegate, to: method_name)
    end
  end
end
