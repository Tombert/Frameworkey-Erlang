-module(routing).
-export([get_routes/0]).
 

get_routes() ->
    JSON = <<"{\"GET /method\": \"mycontroller.action mycontroller.action2\", \"POST /method\": \"mycontroller.action mycontroller.action2\"}">>,
    Routes = jsx:decode(JSON),
    FormatRoutes = lists:map(fun create_cowboy_route/1, Routes),
    RouteMap = squish_to_map(FormatRoutes, #{}),
    Keys = maps:keys(RouteMap),
    Blah = lists:map(fun(Key) -> convert_to_cowboy_route(Key, maps:get(Key, RouteMap)) end, Keys),
    io:format("Hello ~p~n~n~n", [Blah]),
    Blah.

    

convert_to_cowboy_route(EndPoint, Map) ->
    {EndPoint, http_glue, [Map]}.

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

create_cowboy_route({Path, ActionPath}) ->
    [Method, EndPoint] = binary:split(Path, <<" ">>),
    Actions = binary:split(ActionPath, <<" ">>),
    
    Methods = lists:map(fun atomize/1, Actions),
    BigFunc = fn:multicompose(Methods),
    {EndPoint, Method, BigFunc}.
    
