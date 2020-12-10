# frozen_string_literal: true

# :reek:MissingSafeMethod { exclude: [ reject_protected_attributes! ] }
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  PROTECTED_ATTRIBUTES = [].freeze

  scope :not, ->(scope) { where(scope.arel.constraints.reduce(:and).not) }

  # Prevent protected attributes of the model from being exposed in serialized
  # representations of the model.
  def serializable_hash(options = nil)
    options = options&.dup || {}
    (options[:except] ||= []).push(*(self.class::PROTECTED_ATTRIBUTES || [])).uniq!
    %i[methods only].each { |opt| reject_protected_attributes!(options[opt]) }

    super
  end

  private

  def reject_protected_attributes!(array)
    array&.reject! { |val| self.class::PROTECTED_ATTRIBUTES.include?(val) }
  end
end
