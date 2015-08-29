require 'nationbuilder'
require 'csv'

module NB; end

class NB::ApiClient
  attr_reader :slug

  def initialize(slug, token, site_slug = nil)
    @slug = slug
    @client = NationBuilder::Client.new(slug, token)
    @site_slug = site_slug || slug
  end

  def get_resource_index(resource)
    @client.call(resource, :index, limit: 100)
  end

  def get_page_resource_with_id(resource, id)
    @client.call(resource, :index, site_slug: @site_slug, id: id, limit: 100)
  end

  def paginate(request)
    NationBuilder::Paginator.new(@client, request)
  end
end

class NB::CsvHandler
  def initialize(client)
    @client = client
  end

  def parse_data(request, csv)
    results = request.body['results']
    results.each do |result|
      csv << result.values
    end
    parse_data(request.next, csv) if request.next?
  end

  def retrieve_blog_post_headers(blog_id)
    @client.get_page_resource_with_id(:blog_posts, blog_id)['results'].first.keys
  end

  def create_blog_post_csv(blog_id)
    CSV.open("#{@client.slug}_blog_post_api_index.csv", 'w') do |csv|
      csv << retrieve_blog_post_headers(blog_id)
      request = @client.get_page_resource_with_id(:blog_posts, blog_id)
      page = @client.paginate(request)
      parse_data(page, csv)
    end
  end

  def retrieve_people_headers
    @client.get_resource_index(:people)['results'].first.keys
  end

  def create_people_csv
    CSV.open("#{@client.slug}_people.csv", 'w') do |csv|
      csv << retrieve_people_headers
      request = @client.get_resource_index(:people)
      page = @client.paginate(request)
      parse_data(page, csv)
    end
  end

  def retrieve_donation_headers
    @client.get_resource_index(:donations)['results'].first.keys
  end

  def create_donation_csv
    CSV.open("#{@client.slug}_donations.csv", 'w') do |csv|
      csv << retrieve_donation_headers
      request = @client.get_resource_index(:donations)
      page = @client.paginate(request)
      parse_data(page, csv)
    end
  end
end

# Example to pull all blog posts into a csv
#
# client = NB::ApiClient.new(my_nation_slug, test_token)
# csv_handler = NB::CsvHandler.new(client)
# csv_handler.create_blog_post_csv(1)
#