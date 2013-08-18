require "date"

class Post
  @blog = YAML.load_file "config/blog.yml"
  attr_accessor :slug, :title, :content, :created_at
 
  def initialize(slug, title, content, created_at)
    @slug = slug
    @title = title
    @content = content
    @created_at = created_at
  end
  
  def path
    "/blog/#{slug}"
  end
  def imgpath
    "/img/#{slug}.png"
  end
  
  def prev?
    Post.array.first != self
  end
  
  def prev
    ret = Post.array
    ret[ret.index(self) - 1]
  end
  
  def next?
    Post.array.last != self
  end
  
  def next 
    ret = Post.array
    ret[ret.index(self) + 1]
  end
  
  def self.find_all_posts
    @blog["posts"].map { |line| line.strip.split(/\s+/) }.map do |slug, date|
      filename = "blog/#{slug}.md"
      content = File.read(filename)
      created_at = date || Time.now.strftime("%Y-%m-%d")
      next unless content =~ /\A# (.*)$/
      Post.new(slug, $1, $'.strip, created_at)
    end.compact
  end 
  
  def self.all
    @@all ||= Hash[find_all_posts.map { |p| [p.slug, p] }]
  end
  
  def self.clear_cache!
    @@all = nil
  end
  
  def self.array
    all.to_a.map { |k, v| v }.sort! { |a,b| a.created_at <=> b.created_at }
  end
  
  def self.recent
    array.reverse
  end
  
  def self.latest
    recent.first
  end
  
  def self.find(slug)
    all[slug] or raise NotFound
  end
  
  class NotFound < StandardError; end
end