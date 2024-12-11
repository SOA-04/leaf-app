# frozen_string_literal: true

require 'securerandom'
require_relative '../../../../config/environment'
require_relative '../../../presentation/view_objects/query'
require_relative '../../forms/new_query'
require_relative '../../services/queries/add_query'
require_relative '../../services/queries/get_query'

module Leaf
  # Application
  class App < Roda
    plugin :multi_route
    plugin :flash

    route('queries') do |routing| # rubocop:disable Metrics/BlockLength
      routing.post 'submit' do
        query_request = Forms::NewQuery.new.call(routing.params)
        query_result = Service::AddQuery.new.call(query_request)

        if query_result.failure?
          puts(query_result.failure)
          flash[:error] = query_result.failure
          routing.redirect '/queries'
        end

        query_id = query_result.value!
        routing.session[:visited_queries] ||= []
        routing.session[:visited_queries].insert(0, query_id[:id]).uniq!
        flash[:notice] = "Query #{query_id[:id]} created."
        routing.redirect query_id[:id]
      end

      routing.is do
        routing.get do
          routing.scope.view 'query/query_form'
        end
      end

      routing.on String do |query_id|
        routing.get do
          query = Service::GetQuery.new.call(query_id)

          if query.failure?
            puts(query.failure)
            flash[:error] = query_result.failure
            routing.redirect '/queries'
          end

          query_view = Views::Query.new(query.value!)
          routing.scope.view('query/query_result', locals: { query: query_view })
        end
        routing.delete do
          routing.session[:visited_queries].delete(query_id)
          flash[:notice] = "Query '#{query_id}' has been removed from history."
          routing.redirect '/queries'
        end
      end
    end
  end
end
