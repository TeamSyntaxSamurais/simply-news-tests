require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  #### Replace with actual database name ####
  #:database => 'database_name'
)

#### Create routes ####

def ng_to_json url
  @ng = Nokogiri::XML(open(url))
  return Hash.from_xml(@ng.to_xml).to_json
end

get '/nyt' do
  ng_to_json "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
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
  @title = 'News Feed'
  @source = ng_to_json "http://www.npr.org/rss/rss.php?id=1001"
  return @doc_json
  erb :feed
end
