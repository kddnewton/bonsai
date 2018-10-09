# frozen_string_literal: true

module Ext
  # In a lot of objects (especially query objects) we need to reference multiple
  # arel tables. Before this module, the convention was to build a bunch of
  # methods named after the classes that memoized and returned the arel table.
  #
  # As an example, if the query needed to reference the arel table representing
  # the users table, a method would be built like so:
  #
  #     def users
  #       @users ||= User.arel_table
  #     end
  #
  # Alternatively, if the query was using a common table expression or something
  # else that required a table that wasn't directly linked to a database table,
  # they would be created like so:
  #
  #     def complete_items
  #       @complete_items ||= Arel::Table.new(:complete_items)
  #     end
  #
  # For more complex queries, this added a lot of bulk to the various query
  # classes. Instead, you can include this module and specify which tables
  # should be built, as in:
  #
  #     include Ext::ArelTables.new(:users, :complete_items)
  #
  # And those methods will be built automatically. Note that memoization is
  # happening because blocks hold reference to their parent context, so the
  # tables will not be rebuilt/queried.
  #
  # === Aliasing
  #
  # In some cases, you'll want to alias the tables in order to reference them
  # multiple times in the same query. In this case, you can pass a hash with a
  # single key/value pair, where the key is the original table name and the
  # value is the alias, as in:
  #
  #     include Ext::ArelTables.new(users: :creators)
  #
  # You can then reference this table using the alias.
  class ArelTables < Module
    def initialize(*table_names)
      table_names.each do |table_name|
        table_name, table_alias = table_name.first if table_name.is_a?(Hash)
        arel_table = arel_table_for(table_name)

        if table_alias
          define_aliased_table_name_method(table_alias, arel_table)
        else
          define_normal_table_name_method(table_name, arel_table)
        end
      end
    end

    private

    def define_normal_table_name_method(table_name, arel_table)
      define_method(table_name) { arel_table }
    end

    def define_aliased_table_name_method(table_alias, arel_table)
      define_method(table_alias) { arel_table.alias(table_alias) }
    end

    def arel_table_for(table_name)
      Object.const_get(table_name.to_s.classify).arel_table
    rescue NameError
      Arel::Table.new(table_name)
    end
  end
end
