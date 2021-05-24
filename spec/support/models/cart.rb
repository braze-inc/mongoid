# frozen_string_literal: true
# encoding: utf-8

class Cart 
  include Mongoid::Document

  field :items, type: Array
end
