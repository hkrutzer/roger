require File.dirname(__FILE__) + "/release"
require File.dirname(__FILE__) + "/server"
require File.dirname(__FILE__) + "/mockupfile"

module HtmlMockup
  # Loader for mockupfile
  class Project
    
    # @attr :path [Pathname] The project path
    # @attr :html_path [Pathname] The path of the HTML mockup
    # @attr :partial_path [Pathname] The path for the partials for this mockup
    # @attr :mockupfile [Mockupfile] The Mockupfile for this project
    attr_accessor :path, :html_path, :partial_path, :mockupfile
    
    def initialize(path, options={})
      @path = Pathname.new(path)
      
      options = {
        :html_path => @path + "html",
        :partial_path => @path + "partials"
      }.update(options)
      
      paths = mockup_paths(options[:html_path], options[:partial_path])
      self.html_path = paths[0]
      self.partial_path = paths[1]
      
      @mockupfile = Mockupfile.new(self)
      @mockupfile.load
    end
    
    def server
      @server ||= Server.new(self.html_path, self.partial_path)
    end
    
    def release
      @release ||= Release.new(self)
    end
    
    def html_path=(p)
      @html_path = Pathname.new(p).realpath
    end
    
    def partial_path=(p)
      @partial_path = Pathname.new(p).realpath
    end
        
    protected
    
    def mockup_paths(html_path, partial_path = nil)
      html_path = Pathname.new(html_path)
      partial_path = partial_path && Pathname.new(partial_path) || (html_path + "../partials/")
      [html_path, partial_path]
    end


  end
end
