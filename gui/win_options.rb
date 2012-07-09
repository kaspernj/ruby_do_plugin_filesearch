class Ruby_do_plugin_filesearch::Gui::Win_options
  attr_reader :box
  
  def initialize(args)
    @args = args
    
    @gui = Gtk::Builder.new.add("#{File.dirname(__FILE__)}/../glade/win_options.glade")
    @gui.connect_signals{|h| method(h)}
    Knj::Gtk2.translate(@gui)
    
    
    #Initialize treeview.
    Knj::Gtk2::Tv.init(@gui["tvFolders"], [
      _("ID"),
      _("Folder")
    ])
    @gui["tvFolders"].columns[0].visible = false
    @gui["tvFolders"].selection.signal_connect("changed", &self.method(:on_tvFolders_changed))
    self.reload_folders
    self.selected_folder = nil
    
    
    #Make treeview reload when adding, update or delete happens.
    @reload_id = @args[:filesearch].ob.connect("object" => :Plugin_filesearch_folder, "signals" => ["add", "update", "delete"], &self.method(:reload_folders))
    
    
    @box = @gui["boxArguments"]
    @gui["window"].remove(@box)
  end
  
  def reload_folders
    @gui["tvFolders"].model.clear
    
    Knj::Gtk2::Tv.append(@gui["tvFolders"], ["", _("Add new")])
    @args[:filesearch].ob.list(:Plugin_filesearch_folder, "orderby" => "path") do |folder|
      Knj::Gtk2::Tv.append(@gui["tvFolders"], [
        folder.id,
        folder[:path]
      ])
    end
  end
  
  def selected_folder
    sel = Knj::Gtk2::Tv.sel(@gui["tvFolders"])
    return nil if !sel or sel[0].to_i <= 0
    return @args[:filesearch].ob.get(:Plugin_filesearch_folder, sel[0])
  end
  
  def selected_folder=(folder)
    if !folder
      @gui["tvFolders"].selection.select_iter(@gui["tvFolders"].model.iter_first)
      return nil
    end
    
    @gui["tvFolders"].model.each do |model, path, iter|
      id_val = model.get_value(iter, 0).to_i
      
      if id_val == folder.id.to_i
        @gui["tvFolders"].selection.select_iter(iter)
        return nil
      end
    end
  end
  
  def on_btnSave_clicked
    if !Knj::Php.is_numeric(@gui["txtMaxDepth"].text)
      Knj::Gtk2.msgbox(_("Please enter a numeric value in the search-depth."))
      return nil
    end
    
    save_hash = {
      :path => @gui["fcbFolder"].current_folder,
      :search_depth => @gui["txtMaxDepth"].text
    }
    
    if folder = selected_folder
      folder.update(save_hash)
    else
      folder = @args[:filesearch].ob.add(:Plugin_filesearch_folder, save_hash)
    end
    
    self.selected_folder = folder
  end
  
  def on_btnDelete_clicked
    @args[:filesearch].ob.delete(selected_folder)
    self.selected_folder = nil
  end
  
  def on_tvFolders_changed(*args)
    if folder = selected_folder
      @gui["btnDelete"].visible = true
      @gui["fcbFolder"].current_folder = folder[:path]
      @gui["txtMaxDepth"].text = folder[:search_depth]
    else
      @gui["btnDelete"].visible = false
      @gui["fcbFolder"].current_folder = Knj::Os.homedir
      @gui["txtMaxDepth"].text = ""
    end
  end
  
  def on_boxArguments_destroy
    @args[:filesearch].ob.unconnect("object" => :Plugin_filesearch_folder, "conn_id" => @reload_id)
  end
end