# frozen_string_literal: true

require 'securerandom'
require 'ostruct'
require 'dry/transaction'
require_relative '../../../infrastructure/web_api/queries'
require_relative '../../representers/query'

module Leaf
  module Service
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class GetQuery
      include Dry::Transaction

      step :fetch
      step :parse_object

      private

      def fetch(input)
        result = WebAPI::API.new(App.config.API_URL).get_query(input)

        Success(result)
      rescue StandardError => e
        Failure("Calling API: #{e}")
      end

      def parse_object(input)
        result = Representer::Query.new(OpenStruct.new).from_hash(input)
        Success(result)
      rescue StandardError => e
        Failure("Parsing response for Query::Get : #{e}")
      end
    end
  end
end
