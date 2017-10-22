require_relative './useragent'
require_relative './sitemap'


class RobotsAnalyzer
  @@ua_identifier = "User-agent: "  # user-agent identifier
  @@sm_identifier = "Sitemap: "  # site-map identifier

  def initialize(robots_url)
    @robot_url = robots_url
    @robot_content = getTargetContent
    @useragents = (extractUseragentsAndRules).map { |useragent, rules|
        Useragent.new(useragent, rules) unless useragent.nil? or rules.nil?
    }.delete_if { |userAgent| userAgent.nil? }
    @sitemaps = extractSitemaps
  end

  def show
    puts "@robot_url #{@robot_url}"
    puts "@useragents #{@useragents}"
    @useragents.map do |useragent| useragent.show end
    @sitemaps.map do |sitemap| sitemap.show end
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

  def extractUseragentsAndRules

    def extractUseragent (line)
      line[(line.index(@@ua_identifier) + @@ua_identifier.length)..line.length]
    end

    useragents = {}
    useragent = rule = nil

    @robot_content.split("\n").map { |line|
      new_useragent = extractUseragent line unless line[@@ua_identifier].nil?
      useragent = new_useragent unless new_useragent.nil?
      useragents[useragent] = [] if useragents[useragent].nil?
      rule = line if line[@@ua_identifier].nil? and line[@@sm_identifier].nil? and line.start_with?("#")
      useragents[useragent].push(rule) unless useragent.nil? or rule.nil? or rule.empty?
    } unless @robot_content.nil?

    useragents
  end

  def extractSitemaps

    def extractSitemap (line)
      line[(line.index(@@sm_identifier) + @@sm_identifier.length)..line.length]
    end

    @robot_content.split("\n").map { |line|
      sitemap = extractSitemap line unless line[@@sm_identifier].nil?
      SiteMap.new(sitemap) unless sitemap.nil?
    }.compact

  end

end
