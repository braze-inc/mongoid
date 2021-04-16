# frozen_string_literal: true
# encoding: utf-8

module Mongoid

  # Provides behavior for generating the selector for a specific document.
  #
  # @since 4.0.0
  module Selectable
    extend ActiveSupport::Concern

    # Get the atomic selector for the document. This is a hash in the simplest
    # case { "_id" => id }, but can become more complex for embedded documents
    # and documents that use a shard key.
    #
    # @example Get the document's atomic selector.
    #   document.atomic_selector
    #
    # @return [ Hash ] The document's selector.
    #
    # @since 1.0.0
    def atomic_selector
      # Instance variable caching for @atomic_selector has been removed because
      # it has been proven to cause multiple bugs. Mongoid has fixed one of
      # those bugs by removing the @atomic_selector instance variable during
      # the reload method. However, this caching still has the potential to
      # cause more bugs when any consumers of @atomic_selector are called
      # during post-persist callback.
      #
      # I (dalton.black@braze.com) have already raised this issue with Mongoid
      # in some capacity (MONGOID-5076/5078). I will continue to push on the
      # full scope of this caching issue.
      embedded? ? embedded_atomic_selector : root_atomic_selector
    end

    private

    # Get the atomic selector for an embedded document.
    #
    # @api private
    #
    # @example Get the embedded atomic selector.
    #   document.embedded_atomic_selector
    #
    # @return [ Hash ] The embedded document selector.
    #
    # @since 4.0.0
    def embedded_atomic_selector
      if persisted? && _id_changed?
        _parent.atomic_selector
      else
        _parent.atomic_selector.merge("#{atomic_path}._id" => _id)
      end
    end

    # Get the atomic selector for a root document.
    #
    # @api private
    #
    # @example Get the root atomic selector.
    #   document.root_atomic_selector
    #
    # @return [ Hash ] The root document selector.
    #
    # @since 4.0.0
    def root_atomic_selector
      { "_id" => _id }.merge!(shard_key_selector)
    end
  end
end
