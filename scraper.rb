require 'open-uri'


websites = [
  'google.com', 'amazon.com', 'paypal.com', 'pgdsjk.gprejg'
]

headers = ['https', 'http']

websites_urls = websites.map do |website|
  { website => headers.map { |header| "#{header}://#{website}" } }
end


class Website
  def initialize(website_url)
    @robot_url = website_url
    @robot_content = getTargetContent
  end

  def show
    puts "@robot_url #{@robot_url}"
    puts "@robot_content #{@robot_content}"
  end

  private

  def getTargetContent
    begin
        content = open(@robot_url).read unless @robot_url.nil?
        content unless content.nil? || !content['User-agent']
    rescue Errno::ECONNREFUSED => error
        nil
    end
  end
end


class RobotScraper
  def initialize(websites_urls)
    # @websites_urls = websites_urls
    @targets = (valid_urls websites_urls).map do |target|
      target.map { |website, url|  Website.new(url) unless url.nil? }
    end
  end

  def show
    puts "websties_urls #{@websites_urls}"
    @targets.map do |target| target.map { |t| t.show } end
    puts
  end

  private

  def valid_urls(websites_urls)
    websites_urls.map do |target|
      target.map { |website, urls|
        urls.map { |url|
          robot_url = "#{url}/robots.txt"
          { website => robot_url } unless (validator robot_url).nil?
        }.compact.first
      }.compact.first
    end
  end

  def validator(robot_url)
    begin
        !open(robot_url).nil?
    rescue Errno::ECONNREFUSED => error
        nil
    end
  end

end

rs = RobotScraper.new(websites_urls)
rs.show
