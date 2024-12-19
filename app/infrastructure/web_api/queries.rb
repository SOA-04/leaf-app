# frozen_string_literal: true

require 'http'
require 'json'
require_relative '../utils'

module Leaf
  module WebAPI
    # This is the gateway class to make API requests to our backend API.
    # The endpoint will be determined by the provided environmental variable
    class API
      def initialize(endpoint)
        @http = HTTP.accept(:json).persistent(endpoint)
      end

      def get_query(id)
        response = @http.get("/queries/#{id}")

        Response.new(response)
                .handle_error("by Query::Get, status: #{response.status}, message: #{response.parse['message']}")
      end

      # Given 2 points and the travel strategy, obtain the distance and travel time.
      # Refer to: https://developers.google.com/maps/documentation/distance-matrix/distance-matrix
      # @param  origin      [String]  Can be addresses or coordinate.
      # @param  destination [String]  Can be addresses or coordinate.
      # @option strategy    [String]  Possible values are ['driving', 'walking', 'transit', 'bicycling']
      def create_query(origin, destination, strategy = 'walking')
        response = @http.post('/queries', json: {
                                destination: destination,
                                origin: origin,
                                strategy: strategy
                              })

        Response.new(response)
                .handle_error("by Query::Create, status: #{response.status}, message: #{response.parse['message']}")
      end
    end
  end
end
