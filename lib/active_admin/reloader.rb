module ActiveAdmin
  # Deals with reloading Active Admin on each request in 
  # development and once in production.
  class Reloader

    # @param [String] rails_version
    #   The version of Rails we're using. We use this to switch between
    #   the correcr Rails reloader class.
    def initialize(rails_version)
      @rails_version = rails_version.to_s
      @@mtimes = Dir["#{Rails.root}/app/admin/*"].map{|f| File.mtime(f) }.flatten.max
    end

    # Attach to Rails and perform the reload on each request.
    def attach!
      reloader_class.to_prepare do
        return unless ActiveAdmin::Reloader.need_reload?
        ActiveAdmin.application.unload!
        Rails.application.reload_routes!
      end
    end

    def reloader_class
      if @rails_version[0..2] == '3.1'
        ActionDispatch::Reloader
      else
        ActionDispatch::Callbacks
      end
    end

    def self.need_reload?
      changed_at = Dir["#{Rails.root}/app/admin/*"].map{|f| File.mtime(f) }.flatten.max
      if @@mtimes < changed_at
        @@mtimes = changed_at
        STDERR.puts ">>>>>>>>>>>>>>>>>>>   RELOAD!"
        true
      else
        false
      end
    end

  end
end
