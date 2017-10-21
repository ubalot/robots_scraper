require 'open-uri'


websites = [
  'google.com', 'amazon.com', 'paypal.com', 'pgdsjk.gprejg'
]
websites = ['google.com']


headers = ['https', 'http']

websites_urls = websites.map do |website|
  { website => headers.map { |header| "#{header}://#{website}" } }
end


class Useragent
  def initialize(useragent, rules)
    @useragent = useragent
    @rules = rules
  end

  def show
    puts "useragent #{@useragent}"
    puts "rules #{@rules}"
  end
end


class Website
  @@ua_identifier = "User-agent: "  # user-agent identifier
  @@sm_identifier = "Sitemap: "  # site-map identifier

  def initialize(website_url)
    @robot_url = website_url
    @robot_content = getTargetContent
    useragents = extractUseragentAndRules
    @useragents = useragents.map { |useragent, rules|
        Useragent.new(useragent, rules) unless useragent.nil? or rules.nil?
    }.flatten
  end

  def show
    puts "@robot_url #{@robot_url}"
    # puts "@robot_content #{@robot_content}"
    puts "@useragents #{@useragents}"
    @useragents.map do |useragent| useragent.show end
  end

  private

  def getTargetContent
    begin
        content = open(@robot_url).read unless @robot_url.nil?
        content unless content.nil? or content['User-agent'].nil?
    rescue Errno::ECONNREFUSED => error
        nil
    end
  end

  def extractUseragentAndRules

    def extractUseragent (line)
      line[(line.index(@@ua_identifier) + @@ua_identifier.length)..line.length] unless line[@@ua_identifier].nil?
    end

    useragents = {}
    useragent = rule = nil

    @robot_content.split("\n").map do |line|
      new_useragent = extractUseragent line
      useragent = new_useragent unless new_useragent.nil?
      useragents[useragent] = [] if useragents[useragent].nil?
      rule = line if line[@@ua_identifier].nil? and line.index("#") != 0
      useragents[useragent].push(rule) unless useragent.nil? or rule.nil? or rule.empty?
    end

    useragents
  end

end


class RobotScraper
  def initialize(websites_urls)
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
