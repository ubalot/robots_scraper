class SiteMap

  def initialize(sitemap_url)
    @sitemap = sitemap_url
  end

  def show
    puts "@sitemap #{@sitemap}"
  end

end
