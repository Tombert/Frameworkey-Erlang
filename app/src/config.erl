-module(config). 
-export([make_config/0, fetch/1]).

make_config() ->
    {ok, JSON} = file:read_file("config.json"),
    ConfigMap = jsx:decode(JSON, [return_maps]),
    {ok, DLString} = create_download_dir(ConfigMap),
    ets:new(config_table, [named_table, protected, set, {keypos, 1}]),
    ets:insert(config_table, {download_dir, DLString}).

fetch(Field) ->
    [{_, Value}] = ets:lookup(config_table, Field),    
    Value.
    
    
create_download_dir(ConfigMap) ->
    DLBin = maps:get(<<"download_tmp">>, ConfigMap),
    DLString = binary_to_list(DLBin),
    {filelib:ensure_dir(DLString), DLString}.
