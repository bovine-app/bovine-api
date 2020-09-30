# frozen_string_literal: true

# General application errors.
module Errors
  # User password authentication failure error.
  class AuthenticationError < StandardError; end
end
