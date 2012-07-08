class Ruby_do_plugin_filesearch < Ruby_do::Plugin::Base
  class Gui
    def self.const_missing(name)
      require "#{File.dirname(__FILE__)}/../gui/#{name.to_s.downcase}.rb"
      return const_get(name)
    end
  end
  
  def on_options
    win_options = Ruby_do_plugin_filesearch::Gui::Win_options.new
    
    return {
      :widget => win_options.box
    }
  end
  
  def on_search(args)
    return Enumerator.new do |yielder|
      yielder << Ruby_do::Plugin::Result.new(
        :icon => "/usr/share/pixmaps/gnome-log.png",
        :title => _("Test"),
        :descr => _("This is a test.")
      )
    end
  end
end