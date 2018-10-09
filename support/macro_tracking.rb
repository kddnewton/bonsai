# frozen_string_literal: true

module Support
  # Hook into various macros to make sure those don't go stale.
  module MacroTracking
    def self.calls
      @calls ||= {}
    end

    def self.init(key)
      calls[key] = 0
    end

    def self.incr(key)
      calls[key] += 1
    end

    def delegate(*, **)
      super.map do |method_name|
        tracking_key = "#{name}##{method_name}"
        MacroTracking.init(tracking_key)

        untracked = "untracked_#{method_name}"
        alias_method untracked, method_name

        define_method(method_name) do |*args|
          MacroTracking.incr(tracking_key)
          send(untracked, *args)
        end
      end
    end

    def scope(scope_name, *)
      method_name = super
      return if defined_enums.any? { |enum| enum[1].key?(method_name.to_s) }

      tracking_key = "#{name}::#{method_name}"
      MacroTracking.init(tracking_key)

      untracked = "untracked_#{method_name}"
      singleton_class.alias_method untracked, method_name

      define_singleton_method(method_name) do |*args|
        MacroTracking.incr(tracking_key)
        send(untracked, *args)
      end
    end
  end
end

ActiveRecord::Base.singleton_class.prepend(Support::MacroTracking)
