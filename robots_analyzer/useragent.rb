class Useragent

  def initialize(useragent, rules)
    @useragent = useragent
    @rules = rules
  end

  def show
    puts "useragent #{@useragent}"
    puts "rules #{@rules}"
  end

  def getAllowRules
    getRulesByKey "Allow: "
  end

  def getDisallowRules
    getRulesByKey "Disallow: "
  end

  private

  def getRulesByKey(key)
    @rules.map { |rule|
      type = key
      rule[type.length..rule.length] unless rule[type].nil?
    }.compact
  end
end
