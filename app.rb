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
    {
      :name => 'BBC',
      :url => 'http://feeds.bbci.co.uk/news/rss.xml'
    },
    {
      :name => 'NPR',
      :url => 'http://www.npr.org/rss/rss.php?id=1001'
    },
    {
      :name => 'Reuters',
      :url => 'http://feeds.reuters.com/reuters/topNews'
    },
    {
      :name => 'CNN',
      :url => 'http://rss.cnn.com/rss/cnn_topstories.rss'
    }
  ]
  return { :set => true }.to_json
end

def rss_to_hash url, qty=2
  items = Nokogiri::XML(open(url))
  items = Hash.from_xml(items.to_xml)["rss"]["channel"]["item"]
  items.each do |item|
    item["description"] = item["description"].split('<br')[0]
  end
  puts items
  return items[0..qty]
end

get '/reuters' do
  @doc = Nokogiri::XML(open("http://feeds.reuters.com/reuters/topNews"));
  @doc_json = Hash.from_xml(@doc.to_xml).to_json
  return @doc_json;
end

get '/npr' do
  @doc = Nokogiri::XML(open("http://www.npr.org/rss/rss.php?id=1001"));
  @doc_json = Hash.from_xml(@doc.to_xml).to_json
  return @doc_json;
end

get '/feed' do
  erb :feed
end
