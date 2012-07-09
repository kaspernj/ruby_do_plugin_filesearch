class Ruby_do_plugin_filesearch::Gui
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/../gui/#{name.to_s.downcase}.rb"
    return const_get(name)
  end
end