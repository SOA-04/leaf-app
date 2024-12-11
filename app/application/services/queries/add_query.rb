# frozen_string_literal: true

require 'securerandom'
require 'dry/transaction'
require_relative '../../../infrastructure/web_api/queries'

module Leaf
  module Service
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class AddQuery
      include Dry::Transaction

      step :validate_input
      step :call_api

      private

      def validate_input(input)
        if input.success?
          Success(origin: input[:origin], destination: input[:destination], strategy: input[:strategy])
        else
          Failure("Check your input: Something #{input.errors.messages.first}")
        end
      end

      def call_api(input)
        result = WebAPI::API.new(App.config.API_URL).create_query(
          input[:origin], input[:destination], input[:strategy]
        )

        Success(id: result['id'])
      rescue StandardError => e
        Failure("Calling API: #{e}")
      end
    end
  end
end
