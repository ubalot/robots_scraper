require 'open-uri'

require_relative './robots_analyzer/robots_analyzer'


DEBUG = true

ROBOT_LIST_FILE = "robots_list.txt"

websites = []
File.open(ROBOT_LIST_FILE, "r") do |f|
  f.each_line do |line|
    line["\n"] = ""  # avoid '\n' at the end of the string
    websites.push(line) unless line.empty?
  end
end
websites = websites.uniq

# websites = ['google.com'] if DEBUG

headers = ['https', 'http']

websites_urls = Hash[websites.map { |website|
    [ website, headers.map { |header| "#{header}://#{website}" } ]
  }
]


class RobotsScraper

  def initialize(websites_urls)
    # puts "websites_urls #{websites_urls}" if DEBUG
    @targets = Hash[websites_urls.map { |website, urls|
      puts "URL #{urls}"
      url = urls.map { |url|
        robots_url = url + "/robots.txt"#{}"#{url}/robots.txt"
        robots_url if exists robots_url
      }.first
      [ website, url ]
     }].delete_if { |website, url| url.nil? }.map { |website, url|
      puts "website #{website}"
      puts "url #{url}"
      [website, RobotsAnalyzer.new(url)]
    }
  end

  def show
    puts "targets #{@targets}"
    @targets.map { |website, robotsAnalyzer| robotsAnalyzer.show }
    puts
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
rs.show
