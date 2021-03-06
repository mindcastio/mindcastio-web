
require 'uri'
require 'mindcast/connection'
require 'mindcast/jsonapi'

class SearchController < ApplicationController

  def index
    @page = 1
    @limit = 10
  end

  # POST '/search'
  def search
    con = Mindcast::Connection.new(Rails.application.secrets.api_url, {})

    # parse parameters
    @limit = 10
    @page = params[:page].to_i
    @from = 1 + ((@page - 1) * @limit)

    if params[:search]
      q = URI.encode(params[:search][:query])
      @page = 1
    else
      q = URI.encode(params[:q])
    end

    # query the full text index
    result = con.get("/api/1/search?q=#{q}&size=#{@limit}&page=#{@page}", {}, :body => nil)

    # parse the result
    @podcasts = {}
    @podcasts['count'] = result['data']['attributes']['count']
    @podcasts['search_term'] = cleanup_query(result['data']['attributes']['search_term'])
    @podcasts['duration'] = result['data']['attributes']['duration']

    if @podcasts['count'] > 0
      @podcasts['podcasts'] = extract_relationship_data(result, 'results')
    else
      @podcasts['podcasts'] = []
      render 'nocasts'
    end

  end


private

  def cleanup_query(s)
    s.gsub!('+',' ') if s.include? '+'
    s
  end

end
