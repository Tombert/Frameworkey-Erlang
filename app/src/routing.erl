-module(routing).
-export([get_routes/0]).
 

get_routes() ->
    JSON = <<"{\"GET /method\": \"mycontroller.action mycontroller.action2\"}">>,
    Routes = jsx:decode(JSON),
    lists:map(fun create_cowboy_route/1, Routes).

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
    {EndPoint, http_glue, [binary_to_list(Method), BigFunc]}.
    
