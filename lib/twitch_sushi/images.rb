module TwitchSushi::V5
  class Images
    attr_reader :large_url, :medium_url, :small_url, :template_url

    def initialize(hash)
      @large_url = hash['large']
      @medium_url = hash['medium']
      @small_url = hash['small']
      @template_url = hash['template']
    end

    def url(width, height)
      @template_url.gsub('{width}', width.to_s).gsub('{height}', height.to_s)
    end
  end
end
