-module(config). 


make_config() ->
    {ok, JSON} = file:read_file("config.json"),
    ConfigMap = jsx:decode(JSON, [return_maps]),
    create_download_dir(ConfigMap),
    {ok, ConfigMap}.

create_download_dir(ConfigMap) ->
    DLBin = maps:get(<<"download_tmp">>, ConfigMap),
    DLString = binary_to_list(DLBin),
    files:ensure_dir(DLString).
