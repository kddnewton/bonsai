# frozen_string_literal: true

module Ext
  module DelegateScope
    # One of the most common patterns in using scopes is effectively delegating
    # the additions on the query to an associated resource. For example, let's
    # say we have a one-to-many relationship and we want to sort the object on
    # the many side by an attribute on the one side. i.e., we have a `Post`
    # class with an association to a `Comment` class and we want to sort the
    # comments by the post title. We could set this up as:
    #
    #     class Post
    #       has_many :comments
    #       scope :by_title, -> { order(title: :asc) }
    #     end
    #
    #     class Comment
    #       belongs_to :post
    #       scope :by_title, -> { joins(:post).merge(Post.by_title) }
    #     end
    #
    # In this case, the `by_title` scope on the `Comment` class is effectively
    # delegating the modifications of the scope of the query to its associated
    # class.
    #
    # This is so common that we've added this `delegate_scope` method, which
    # accomplishes the same thing in fewer lines. In the above example you would
    # use it like:
    #
    #     class Comment
    #       belongs_to :post
    #       delegate_scope :by_title, to: :post
    #     end
    #
    # If you wanted to rename the scope, you can pass a `source` option, as in:
    #
    #     class Comment
    #       belongs_to :post
    #       delegate_scope :by_post_title, to: :post, source: :by_title
    #     end
    #
    # This will create a scope named `by_post_title`, but will still delegate
    # over to `Post::by_title`.
    def delegate_scope(*scope_names, to:, source: :name)
      klass = reflect_on_association(to).klass

      scope_names.each do |scope_name|
        name = source == :name ? scope_name : source

        # rubocop:disable Rails/ScopeArgs
        scope scope_name, delegate_scope_for(to, klass, name)
        # rubocop:enable Rails/ScopeArgs
      end
    end

    private

    def delegate_scope_for(to, klass, name)
      ->(*args) { joins(to).merge(klass.public_send(name, *args)) }
    end
  end
end
