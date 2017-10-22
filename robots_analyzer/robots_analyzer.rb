require_relative './useragent'

class RobotsAnalyzer
  @@ua_identifier = "User-agent: "  # user-agent identifier
  @@sm_identifier = "Sitemap: "  # site-map identifier

  def initialize(robots_url)
    @robot_url = robots_url
    @robot_content = getTargetContent
    @useragents = (extractUseragentAndRules).map { |useragent, rules|
        Useragent.new(useragent, rules) unless useragent.nil? or rules.nil?
    }.delete_if { |userAgent| userAgent.nil? }
    # @sitemaps = extractSitemaps
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

    @robot_content.split("\n").map { |line|
      new_useragent = extractUseragent line
      useragent = new_useragent unless new_useragent.nil?
      useragents[useragent] = [] if useragents[useragent].nil?
      rule = line if line[@@ua_identifier].nil? and line.index("#") != 0 and line[@@sm_identifier].nil?
      useragents[useragent].push(rule) unless useragent.nil? or rule.nil? or rule.empty?
    } unless @robot_content.nil?

    useragents
  end

end