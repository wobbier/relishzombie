require "cgi"
require "yaml"
require "bundler"
require "rinku"
require "time"

Bundler.require :default, :environment
# My Twitter API Application is Read-Only, so showing these keys doesn't matter.
Twitter.configure do |config|
  config.consumer_key = "PdllLdQFJJlgIEyl56Nxow"
  config.consumer_secret = "CSnppogcQWQ74zdpYlgFYibinmYjj7GEcxG3u6b6E"
  config.oauth_token = "60374879-BdetjAgKswVjlDjlDQINjcYH8zTtTfEOSGC4Qjtri"
  config.oauth_token_secret = "UN7eJQ2IpRYhLEFz3F17AnDpAGrTOuglW0zlPIY"
end
# Require all models
Dir["./models/*.rb"].each &method(:require)
helpers do
  # Return an age based off the 
  def age(birthdate)
    date = DateTime.now;
    age = date.year - birthdate.year
    age -= 1 if (birthdate.month >  date.month or (birthdate.month >= date.month and birthdate.day > date.day))
    age
  end
  def to_date(date)
  	time = Time.parse(date)
  	time.strftime("%B %d, %Y")
  end
  def markdown(string)
    GitHub::Markup.render("string.md", string)
  end
  
  def linkto(address, name)
    "<a href=\"#{address}\">#{name}</a>"
  end
  
  def mailto(email, name)
    linkto "mailto:#{email}", name
  end
  
  def escape(string)
    CGI::escape(string)
  end
  
  def lang(language)
    "<a href=\"https://github.com/search?q=%40relishzombie&type=Repositories&ref=advsearch&l=#{escape(language)}\" class=\"lang\">#{language}</a>"
  end
  
  def libr(library)
    "<a href=\"https://github.com/search?l=&q=#{escape(library)}+%40relishzombie&ref=advsearch&type=Code\" class=\"libr\">#{library}</a>"
  end
  
  def lang?(language)
    @portfolio["languages"].each do |lang|
      if lang.downcase == language.downcase 
        return true
      end 
    end
    false
  end
  def parse_tweet(tweet)
    tweet = Rinku.auto_link(tweet)
    hashtag = tweet.scan(/[#][A-z1-9_]*/)
    if !hashtag.nil?
      hashtag.each do |h|
        tweet = tweet.gsub(h, "<a href='https://twitter.com/search?q=#{ h }'>#{ h }</a>").gsub(/[=][#]/, '=')
      end
    end
    username = tweet.scan(/[@][A-z1-9_]*/)
    if !username.nil?
      username.each do |u|
        tweet = tweet.gsub(u, "<a href='https://twitter.com/#{ u }'>#{ u }</a>").gsub(/[\/][@]/, '/')
      end
    end
    return tweet
  end
end

get "/" do
  erb :index
end 

get "/blog" do
  @title = "Blog"
  @posts = Post.recent
  erb :blog
end

get "/blog.rss" do
  @posts = Post.recent
  content_type "application/rss+xml"
  erb :blog_rss, :layout => false
end

get "/blog/:slug.md" do
  post = Post.find params[:slug]
  content_type "text/plain"
  "# #{post.title}\n\n#{post.content}"
end

get "/blog/:slug" do
  @post = Post.find params[:slug]
  @title = @post.title
  erb :blog_post
end
get "/twitter" do
  @title = "Twitter"
  @tweets = Twitter.user_timeline("RobertEvola")
  erb :twitter
end
get "/portfolio" do
  @title = "Portfolio"
  @portfolio = YAML.load_file "config/portfolio.yml"
  erb :portfolio
end
# Social Networks
get "/@" do
  redirect to("http://twitter.com/RobertEvola")
end

get "/~" do
  redirect to("http://github.com/relishzombie")
end

get "/&" do
  redirect to("http://steamcommunity.com/id/evolusion")
end