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
      :id => 1,
      :name => 'The Verge',
      :url => 'http://www.theverge.com/rss/index.xml'
    },
    {
      :id => 2,
      :name => 'Mashable',
      :url => 'http://feeds.mashable.com/Mashable'
    },
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
    },
    {
      :id => 9,
      :name => "New York Times",
      :url => 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
    },
    {
      :id => 10,
      :name => 'ESPN',
      :url => 'http://sports.espn.go.com/espn/rss/news'
    },
    {
      :id => 11,
      :name => 'Wall Street Journal',
      :url => 'http://www.wsj.com/xml/rss/3_7085.xml'
    },
    {
      :id => 12,
      :name => 'Financial Times',
      :url => 'http://www.ft.com/rss/home/us'
    },
    {
      :id => 13,
      :name => 'Yahoo News',
      :url => 'http://news.yahoo.com/rss/'
    },
    {
      :id => 14,
      :name => 'The New Yorker',
      :url => 'http://www.newyorker.com/feed/news'
    },
    {
      :id => 15,
      :name => 'New York Review of Books',
      :url => 'http://feeds.feedburner.com/nybooks'
    },
    {
      :id => 16,
      :name => 'Elle',
      :url => 'http://www.elle.com/rss/all.xml'
    },
    {
      :id => 17,
      :name => 'Glamour',
      :url => 'http://feeds.glamour.com/glamour/glamour_all'
    },
    {
      :id => 18,
      :name => 'Hollywood Reporter',
      :url => 'http://feeds.feedburner.com/thr/news'
    },
    {
      :id => 19,
      :name => 'Yahoo Sports',
      :url => 'https://sports.yahoo.com/top/rss.xml'
    },
    {
      :id => 20,
      :name => 'Hacker News',
      :url => 'https://news.ycombinator.com/rss'
    },
    # {
    #   :id => 21,
    #   :name => 'Newsweek',
    #   :url => 'http://www.newsweek.com/rss'
    # },
    # {
    #   :id => 22,
    #   :name => 'The Economist',
    #   :url => 'http://www.economist.com/sections/united-states/rss.xml'
    # }

  ]
  return { :set => true }.to_json
end

def type_of_rss hash
  if (hash.has_key?('rss'))
    return 'rss1' # NPR-style RSS
  elsif (hash.has_key?('feed'))
    return 'rss2' # Verge-style RSS
  end
end

def parse_link item
  unless item["link"].is_a? String
    if item["link"].is_a? Hash # Verge format
      item["link"] = item["link"]["href"]
    elsif item["link"].is_a? Array # NYT format
      item["link"] = item["link"][0]["href"]
    end
  end
end

def parse_description item
  if item["description"].is_a? Array
    item["description"] = item["description"][0]
  end
end

def rss_to_hash url, qty=false
  page = Nokogiri::XML(open(url))
  hash = Hash.from_xml(page.to_xml)
  type = type_of_rss hash
  if type == 'rss1'
    items = hash["rss"]["channel"]["item"]
    items.each do |item|
      unless item["descripion"].nil?
        item["description"] = item["description"].split('<br')[0]
      end
    end
  elsif type == 'rss2'
    items = hash["feed"]["entry"]
    items.each do |item|
      item['description'] = item['content']
    end
  end
  items.each do |item|
    parse_link item
    parse_description item
  end
  if qty
    return items[0..qty]
  else
    return items
  end
end

get '/' do
  @title = 'News Feed'
  erb :feed
end

get '/:id' do
  key = params[:id].to_i - 1
  @source = session[:sources][key]
  @title = @source[:name]
  erb :single_source
end
