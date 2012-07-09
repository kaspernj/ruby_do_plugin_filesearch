class Ruby_do_plugin_filesearch < Ruby_do::Plugin::Base
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/../include/#{name.to_s.downcase}.rb"
    return const_get(name)
  end
  
  attr_reader :ob
  
  def initialize(*args, &block)
    super(*args, &block)
    
    
    #Update database to contain tables for the plugin.
    Knj::Db::Revision.new.init_db("db" => rdo_plugin_args[:rdo].db, "schema" => Ruby_do_plugin_filesearch::Database::SCHEMA)
    
    
    #Initialize models-framework.
    @ob = Knj::Objects.new(
      :datarow => true,
      :class_path => "#{File.dirname(__FILE__)}/../models",
      :class_pre => "",
      :db => rdo_plugin_args[:rdo].db,
      :module => Ruby_do_plugin_filesearch::Models
    )
  end
  
  def on_options
    win_options = Ruby_do_plugin_filesearch::Gui::Win_options.new(:rdo => self.rdo_plugin_args[:rdo], :filesearch => self)
    
    return {
      :widget => win_options.box
    }
  end
  
  def on_search(args)
    return Enumerator.new do |yielder|
      if !args[:words].empty?
        @ob.list(:Plugin_filesearch_folder) do |folder|
          files = self.scan_dir(folder[:path], :words => args[:words], :depth => 0, :max_depth => folder[:search_depth].to_i) do |file|
            title = sprintf(_("Open '%s'."), file[:name])
            
            yielder << Ruby_do::Plugin::Result.new(
              :plugin => self,
              :title => title,
              :title_html => "<b>#{Knj::Web.html(title)}</b>",
              :descr => sprintf(_("Open the filepath: '%s'."), file[:path]),
              :path => file[:path]
            )
          end
        end
      end
    end
  end
  
  def execute_result(args)
    Knj::Os.subproc("xdg-open \"#{args[:res].args[:path]}\"")
    return :close_win_main
  end
  
  def scan_dir(path, args, &block)
    depth = args[:depth] + 1
    
    Dir.foreach(path) do |file|
      begin
        next if file[0, 1] == "."
        fp = "#{path}/#{file}"
        filel = file.downcase
        
        if File.directory?(fp)
          self.scan_dir(fp, args.merge(:depth => depth), &block) if depth < args[:max_depth]
        else
          all_found = true
          args[:words].each do |word|
            if filel.index(word) == nil
              all_found = false
              break
            end
          end
          
          block.call(:name => file, :path => fp) if all_found
        end
      rescue => e
        $stderr.puts "Error while searching item: '#{e.message}' for '#{fp}'."
      end
    end
  end
end