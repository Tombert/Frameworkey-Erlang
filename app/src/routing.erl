-module(routing).
-export([get_routes/1]).
 

get_routes(PreVars) ->
    {ok, JSON} = file:read_file("routes.json"),
    Routes = jsx:decode(JSON),
    FormatRoutes = lists:map(fun separate_route_parts/1, Routes),
    RouteMap = squish_to_map(FormatRoutes, #{}),
    Keys = maps:keys(RouteMap),
    TempFun = fun(Params) ->
                  maps:merge(Params, PreVars)
              end,
    [ TempFun | lists:map(fun(Key) -> convert_to_cowboy_route(Key, maps:get(Key, RouteMap)) end, Keys)].

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
    [Module, Action] = binary:split(ModuleAction, <<".">>),
    ModAtom = binary_to_atom(Module, unicode),
    ActAtom = binary_to_atom(Action, unicode),
    fun ModAtom:ActAtom/1.

separate_route_parts({Path, ActionPath}) ->
    [Method, EndPoint] = binary:split(Path, <<" ">>),
    Actions = binary:split(ActionPath, <<" ">>),
    
    Methods = lists:map(fun atomize/1, Actions),
    BigFunc = fn:multicompose(Methods),
    {EndPoint, Method, BigFunc}.
    
