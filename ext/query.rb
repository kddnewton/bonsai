# frozen_string_literal: true

module Ext
  # When scopes get too big, they end up involving helper methods, multiple
  # lines of code, etc. That ends up negating the concise nature of single line
  # lambdas, and they end up being difficult to read. Often, it's more desirable
  # to extract that into a separate, testable object, as in:
  #
  #     class User
  #       scope :points_by_department, -> {
  #         Queries::UserPointsByDepartment.new(self).results
  #       }
  #     end
  #
  # This is so common that we've added the `query` method, which accomplishes
  # the same thing in fewer lines. In the above example you would use it like:
  #
  #     class User
  #       query :points_by_department, Queries::UserPointsByDepartment
  #     end
  #
  # You can also pass any arguments to the query and they will just be appended
  # to the initialize method of the query object.
  module Query
    def query(name, constant)
      scope name, ->(*args) { constant.new(self, *args).results }
    end
  end
end
