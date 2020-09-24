# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  PROTECTED_ATTRIBUTES = [].freeze

  # Prevent protected attributes of the model from being exposed in serialized
  # representations of the model.
  def serializable_hash(options = {})
    (options[:except] ||= []).push(*self.class::PROTECTED_ATTRIBUTES).uniq!
    %i[methods only].each { |opt| reject_protected_attributes options[opt] }

    super
  end

  private

  def reject_protected_attributes(array)
    array&.reject! { |val| self.class::PROTECTED_ATTRIBUTES.include?(val) }
  end
end
