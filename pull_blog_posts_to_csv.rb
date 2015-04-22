require 'nationbuilder'
require 'csv'
 
# slug for the nation
slug = ''
# site slug for nation, default is the same as the nation slug if there is only one site
site_slug = slug
# API token, found at slug.nationbuilder.com/admin/oauth/test_tokens
token = ''
 
@csv = CSV.open('output.csv', 'w')
@csv << %w(id slug title excerpt name status headline content_before_flip published_at content)
 
client = NationBuilder::Client.new(slug, token)
 
def parse_data(request)
  results = request.body['results']
  results.each do |result|
    @csv << [
              result['id'],
              result['slug'],
              result['title'],
              result['excerpt'],
              result['name'],
              result['status'],
              result['headline'],
              result['content_before_flip'],
              result['published_at'],
              result['content']
            ] # add to the csv the id and slug of the blog post
  end
  parse_data(request.next) if request.next?
end
 
request = client.call(:blog_posts, :index, site_slug: slug, id: 1, limit: 100) # args for call - site slug and id of the blog_id to pull posts from
page = NationBuilder::Paginator.new(client, request)
parse_data(page)
 
csv.close
