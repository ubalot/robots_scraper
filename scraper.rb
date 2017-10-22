require 'open-uri'

require_relative './robots_analyzer/robots_analyzer'


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
      [website, RobotsAnalyzer.new(url)]
    }
  end

  def show
    # puts "targets #{@targets}"
    @targets.map { |website, robotsAnalyzer| robotsAnalyzer.show }
    puts
  end

  private

  def exists(robots_url)
    begin
        puts "robot_url #{robots_url}" if DEBUG
        true unless open(robots_url).nil? or (open(robots_url).read)['User-agent'].nil?
    rescue Exception
        nil
    end
  end

end

rs = RobotsScraper.new(websites_urls)
rs.show
