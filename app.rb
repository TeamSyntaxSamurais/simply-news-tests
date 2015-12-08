require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  #### Replace with actual database name ####
  #:database => 'database_name'
)

enable :sessions

get '/set-sources' do
  session[:sources] = [
    # {
    #   :id => 1,
    #   :name => 'The Verge',
    #   :url => 'http://www.theverge.com/gaming/rss/index.xml'
    # },
    {
      :id => 3,
      :name => 'Ars Technica',
      :url => 'http://feeds.arstechnica.com/arstechnica/index'
    },
    {
      :id => 4,
      :name => 'Los Angeles Times',
      :url => 'http://www.latimes.com/rss2.0.xml'
    },
    {
      :id => 5,
      :name => 'BBC',
      :url => 'http://feeds.bbci.co.uk/news/rss.xml'
    },
    {
      :id => 6,
      :name => 'NPR',
      :url => 'http://www.npr.org/rss/rss.php?id=1001'
    },
    {
      :id => 7,
      :name => 'Reuters',
      :url => 'http://feeds.reuters.com/reuters/topNews'
    },
    {
      :id => 8,
      :name => 'CNN',
      :url => 'http://rss.cnn.com/rss/cnn_topstories.rss'
    }
  ]
  return { :set => true }.to_json
end

get '/test' do
  rss_to_hash 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml', false

  erb :index
end

def rss_to_hash url, qty
  items = Nokogiri::XML(open(url))

  # items.search('a').each do |a|
  #   a.remove
  # end

  items = Hash.from_xml(items.to_xml)["rss"]["channel"]["item"]
  items.each do |item|
    item["description"] = item["description"].split('<br')[0]
  end
  if qty
    return items[0..qty]
  else
    return items
  end
  return items

end

get '/feed' do
  erb :feed
end
