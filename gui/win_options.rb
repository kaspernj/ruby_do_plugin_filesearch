class Ruby_do_plugin_filesearch::Gui::Win_options
  attr_reader :box
  
  def initialize(args)
    @gui = Gtk::Builder.new.add("#{File.dirname(__FILE__)}/../glade/win_options.glade")
    @gui.connect_signals{|h| method(h)}
    Knj::Gtk2.translate(@gui)
    
    @box = @gui["boxArguments"]
    @gui["window"].remove(@box)
  end
end