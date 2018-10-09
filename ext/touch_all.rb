# frozen_string_literal: true

module Ext
  # With Rails caching, all cache keys are based on the `updated_at` column. In
  # most cases, you can rely on Russian doll caching to handle everything
  # through the `belongs_to` associations. In some cases though, you want to
  # bust the cache of a `has_many` (for instance, busting all user caches when
  # an organization is updated). In this case, you would typically write an
  # `after_save` that would look like:
  #
  #     class Organization
  #       has_many :users
  #       after_save { BustAssociatedCachesJob.perform_later(self, :users) }
  #     end
  #
  # You can accomplish this through this the inclusion of this module, as in:
  #
  #     class Organization
  #       include Ext::TouchAll.new(:users)
  #     end
  #
  # This will build the same `after_save` callback.
  class TouchAll < Module
    attr_reader :touch

    def initialize(*associations, touch: nil)
      @touch = touch
      define_touch_all_related(associations.map(&:to_s))
    end

    # We necessarily want :reek:FeatureEnvy because we're modifying the object
    # into which we're being included
    def included(base)
      base.after_save(:touch_all_related)
      base.after_touch(:touch_all_related) if touch
    end

    private

    def define_touch_all_related(associations)
      define_method(:touch_all_related) do
        BustAssociatedCachesJob.perform_later(self, *associations)
      end
    end
  end
end
