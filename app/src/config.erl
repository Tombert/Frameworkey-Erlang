-module(config). 
-export([make_config/0, fetch/1]).

make_config() ->
    ets:new(config_table, [named_table, protected, set, {keypos, 1}]),
    {ok, JSON} = file:read_file("config.json"),
    ConfigMap = jsx:decode(JSON, [return_maps]),
    create_download_dir(ConfigMap).


fetch(Field) ->
    [{_, Value}] = ets:lookup(config_table, Field),    
    Value.
    
    
create_download_dir(ConfigMap) ->
    DLBin = maps:get(<<"download_tmp">>, ConfigMap),
    DLString = binary_to_list(DLBin),
    ets:insert(config_table, {download_dir, DLString}),
    ok.

