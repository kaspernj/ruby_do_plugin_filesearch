class Ruby_do_plugin_filesearch::Database
  SCHEMA = {
    "tables" => {
      "Plugin_filesearch_folder" => {
        "columns" => [
          {"name" => "id", "type" => "int", "autoincr" => true, "primarykey" => true},
          {"name" => "path", "type" => "text"},
          {"name" => "search_depth", "type" => "text"}
        ]
      }
    }
  }
end