# frozen_string_literal: true

module HTTP
  # Contains classes that are instantiated by being thrown as errors. Instance
  # methods may not refer to self because the class may not have any instance
  # variables.
  # :reek:UtilityFunction
  module Errors
    # Base class for handleable application errors.
    class BaseError < StandardError
      def code
        raise NotImplementedError
      end

      def handle(_controller); end
    end

    # Represents an HTTP 401 Unauthorized error.
    class UnauthorizedError < BaseError
      def code
        :unauthorized
      end

      def handle(controller)
        controller.reset_session
      end
    end

    # Represents an HTTP 403 Forbidden error.
    class ForbiddenError < BaseError
      def code
        :forbidden
      end
    end

    # Represents an HTTP 422 Unprocessable Entity error.
    class UnprocessableEntityError < BaseError
      def code
        :unprocessable_entity
      end
    end
  end
end
