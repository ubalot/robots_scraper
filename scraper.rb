require 'open-uri'

require_relative './robots_analyzer/robots_analyzer'


ROBOT_LIST_FILE = "robots_list.txt"

websites = []
File.open(ROBOT_LIST_FILE, "r") do |f|
  f.each_line do |line|
    line["\n"] = ""  # avoid '\n' at the end of the string
    websites.push(line) unless line.empty?
  end
end
websites = websites.uniq

headers = ['https', 'http']

websites_urls = Hash[websites.map { |website|
    [ website, headers.map { |header| "#{header}://#{website}" } ]
  }
]


class RobotsScraper

  def initialize(websites_urls)
    # @targets is an array of type {<example.org> => RobotAnalyzer}
    @targets = Hash[websites_urls.map { |website, urls|
      url = urls.map { |url|
        robots_url = url + "/robots.txt"
        robots_url if exists robots_url
      }.first
      [ website, url ]
     }].delete_if { |website, url| url.nil? }.map { |website, url|
      { website => RobotsAnalyzer.new(website, url) }
    }.inject(:merge)
  end

  def show
    puts "TARGETS #{@targets}"
    @targets.map { |website, robotsAnalyzer| robotsAnalyzer.show }
    puts
  end

  def getRobotAnalyzerFor(website)
    @targets[website]
  end

  private

  def exists(robots_url)
    begin
        true unless open(robots_url).nil? or (open(robots_url).read)['User-agent'].nil?
    rescue Exception
        nil
    end
  end

end

rs = RobotsScraper.new(websites_urls)
ra = rs.getRobotAnalyzerFor "google.com"
ua = ra.getUseragent "*"
allow_rules = ua.getAllowRules
puts "allow_rules #{allow_rules}"
