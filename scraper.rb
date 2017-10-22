require 'open-uri'


DEBUG = true

ROBOT_LIST_FILE = "robots_list.txt"


websites = [
  'google.com', 'amazon.com', 'paypal.com', 'pgdsjk.gprejg'
].uniq
websites = ['google.com'] if DEBUG


headers = ['https', 'http']

websites_urls = Hash[websites.map { |website|
  [ website, headers.map { |header| "#{header}://#{website}" } ]
  }
]

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


class RobotsTxt
  @@ua_identifier = "User-agent: "  # user-agent identifier
  @@sm_identifier = "Sitemap: "  # site-map identifier

  def initialize(robots_url)
    @robot_url = robots_url
    @robot_content = getTargetContent
    useragents = extractUseragentAndRules
    @useragents = useragents.map { |useragent, rules|
        Useragent.new(useragent, rules) unless useragent.nil? or rules.nil?
    }.delete_if { |userAgent| userAgent.nil? }
  end

  def show
    puts "@robot_url #{@robot_url}"
    puts "@useragents #{@useragents}"
    @useragents.map do |useragent| useragent.show end
  end

  private

  def getTargetContent
    begin
        content = open(@robot_url).read unless @robot_url.nil?
        content unless content.nil? or content['User-agent'].nil?
    rescue Exception
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


class RobotsScraper
  def initialize(websites_urls)
    puts "websites_urls #{websites_urls}" if DEBUG
    @targets = Hash[websites_urls.map { |website, urls|
      url = urls.map { |url|
        robots_url = "#{url}/robots.txt"
        robots_url if exists robots_url
      }.first
      [ website, url ]
    }].delete_if { |website, url| url.nil? }.map { |website, url|
      [website, RobotsTxt.new(url)]
    }
  end

  def show
    # puts "targets #{@targets}"
    @targets.map { |website, robotsTxt|
      robotsTxt.show 
    }
    puts
  end

  private

  def exists(robots_url)
    begin
        puts "robot_url #{robots_url}" if DEBUG
        true unless open(robots_url).nil? or (open(robots_url).read)['User-agent'].nil?
    rescue Exception #Errno::ECONNREFUSED, OpenURI::HTTPError,
        nil
    end
  end

end

rs = RobotsScraper.new(websites_urls)
rs.show
