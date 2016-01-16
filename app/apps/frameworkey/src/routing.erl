-module(routing).
-export([get_routes/1, update_routes/0]).
 
update_routes() ->
    Prevars = config:fetch(prevars),
    Routes = get_routes(Prevars),
    Dispatch = cowboy_router:compile([
        {'_', Routes}
    ]),
    cowboy:set_env(my_http_listener, dispatch, Dispatch).

get_routes(PreVars) ->
    {ok, JSON} = file:read_file(code:priv_dir(frameworkey) ++ "/routes.json"),
    Routes = jsx:decode(JSON),
    FormatRoutes = lists:map(fun(Route) -> separate_route_parts(Route, PreVars) end, Routes),
    RouteMap = squish_to_map(FormatRoutes, #{}),
    Keys = maps:keys(RouteMap),
    lists:map(fun(Key) -> convert_to_cowboy_route(Key, maps:get(Key, RouteMap)) end, Keys).

convert_to_cowboy_route(EndPoint, Map) -> {EndPoint, http_glue, [Map]}.

merge_stuff(false, EndPoint, Method, BigFunc, Map) ->
    maps:put(EndPoint, #{Method => BigFunc}, Map);
merge_stuff(true, EndPoint, Method, BigFunc, Map) ->
    EndPointMap = maps:get(EndPoint, Map),
    NewMethodMap = maps:put(Method, BigFunc, EndPointMap),
    maps:update(EndPoint, NewMethodMap, Map).


squish_to_map([], Map) ->
    Map;
squish_to_map([{EndPoint, Method, BigFunc} | Routes], Map) ->
    ListEndPoint = binary_to_list(EndPoint),
    IsInMap = maps:is_key(ListEndPoint, Map),
    NewMap = merge_stuff(IsInMap, ListEndPoint, Method, BigFunc, Map),
    squish_to_map(Routes, NewMap).


atomize(ModuleAction) ->
    [Module, Action] = binary:split(ModuleAction, <<".">>, [global]),
    ModAtom = binary_to_atom(Module, unicode),
    ActAtom = binary_to_atom(Action, unicode),
    fun ModAtom:ActAtom/1.

separate_route_parts({Path, ActionPath}, PreVars) ->
    [Method, EndPoint] = binary:split(Path, <<" ">>),
    Actions = binary:split(ActionPath, <<" ">>, [global]),
    
    Methods = lists:map(fun atomize/1, Actions),
    TempFun = fun(Params) ->
                  maps:merge(Params, PreVars)
              end,
    BigFunc = fn:multicompose([TempFun | Methods]),
    {EndPoint, Method, BigFunc}.
    
