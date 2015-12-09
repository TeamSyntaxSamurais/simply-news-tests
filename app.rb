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
      :rss_url => 'http://www.theverge.com/rss/index.xml',
      :image_url => '/images/the-verge.png'
    },
    {
      :id => 2,
      :name => 'Mashable',
      :rss_url => 'http://feeds.mashable.com/Mashable',
      :image_url => '/images/mashable.png'
    },
    {
      :id => 3,
      :name => 'Ars Technica',
      :rss_url => 'http://feeds.arstechnica.com/arstechnica/index',
      :image_url => '/images/ars-technica.png'
    },
    {
      :id => 4,
      :name => 'Los Angeles Times',
      :rss_url => 'http://www.latimes.com/rss2.0.xml',
      :image_url => '/images/los-angeles-times.png'
    },
    {
      :id => 5,
      :name => 'BBC',
      :rss_url => 'http://feeds.bbci.co.uk/news/rss.xml',
      :image_url => '/images/bbc-news.png'
    },
    {
      :id => 6,
      :name => 'NPR',
      :rss_url => 'http://www.npr.org/rss/rss.php?id=1001',
      :image_url => '/images/npr.png'
    },
    {
      :id => 7,
      :name => 'Reuters',
      :rss_url => 'http://feeds.reuters.com/reuters/topNews',
      :image_url => '/images/reuters.png'
    },
    {
      :id => 8,
      :name => 'CNN',
      :rss_url => 'http://rss.cnn.com/rss/cnn_topstories.rss',
      :image_url => '/images/cnn.jpg'
    },
    {
      :id => 9,
      :name => "New York Times",
      :rss_url => 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
      :image_url => '/images/nyt.png'
    },
    {
      :id => 10,
      :name => 'ESPN',
      :rss_url => 'http://sports.espn.go.com/espn/rss/news',
      :image_url => '/images/espn.png'
    },
    {
      :id => 11,
      :name => 'Wall Street Journal',
      :rss_url => 'http://www.wsj.com/xml/rss/3_7085.xml',
      :image_url => '/images/wsj.png'
    },
    {
      :id => 12,
      :name => 'Financial Times',
      :rss_url => 'http://www.ft.com/rss/home/us',
      :image_url => '/images/financial-times.png'
    },
    {
      :id => 13,
      :name => 'Yahoo News',
      :rss_url => 'http://news.yahoo.com/rss/',
      :image_url => '/images/yahoo.png'
    },
    {
      :id => 14,
      :name => 'The New Yorker',
      :rss_url => 'http://www.newyorker.com/feed/news',
      :image_url => '/images/the-new-yorker.png'
    },
    {
      :id => 15,
      :name => 'New York Review of Books',
      :rss_url => 'http://feeds.feedburner.com/nybooks',
      :image_url => '/images/nyrb.png'
    },
    {
      :id => 16,
      :name => 'Elle',
      :rss_url => 'http://www.elle.com/rss/all.xml',
      :image_url => '/images/elle.png'
    },
    {
      :id => 17,
      :name => 'Glamour',
      :rss_url => 'http://feeds.glamour.com/glamour/glamour_all',
      :image_url => '/images/glamour.png'
    },
    {
      :id => 18,
      :name => 'Hollywood Reporter',
      :rss_url => 'http://feeds.feedburner.com/thr/news',
      :image_url => '/images/hollywood-reporter.png'
    },
    {
      :id => 19,
      :name => 'Yahoo Sports',
      :rss_url => 'https://sports.yahoo.com/top/rss.xml',
      :image_url => '/images/yahoo-sports.png'
    },
    {
      :id => 20,
      :name => 'Hacker News',
      :rss_url => 'https://news.ycombinator.com/rss',
      :image_url => '/images/hacker-news.png'
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

get '/choose-sources' do
  @sources = session[:sources]
  @title = 'Choose News Sources'
  erb :choose_sources
end
