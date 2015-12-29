-module(routing).
-export([get_routes/0]).
 

get_routes() ->
    JSON = <<"{\"GET /method\": \"mycontroller.action mycontroller.action2\"}">>,
%%    Routes = jsx:decode(JSON, [return_maps]),
    Routes = jsx:decode(JSON),
    lists:map(fun create_cowboy_route/1, Routes).
    %% lists:map(fun(Path) -> 
    %%                   [Method, EndPoint] = string:token(Path, " "),
    %%                   Actions = maps:get(Path
    %%           end, Paths).
    

atomize(ModuleAction) ->
    [Module, Action] = binary:token(ModuleAction),
    fun Module:Action/1.

create_cowboy_route({Path, ActionPath}) ->
    [Method, EndPoint] = binary:token(Path, " "),
    Actions = binary:token(ActionPath, " "),
    
    Methods = lists:map(fun atomize/1, Actions),
    BigFunc = fn:multicompose(Methods),
    {EndPoint, http_glue, [Method, BigFunc]}.
    
