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
