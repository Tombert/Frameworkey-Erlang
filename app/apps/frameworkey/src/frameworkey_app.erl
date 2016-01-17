%%%-------------------------------------------------------------------
%% @doc mylib public API
%% @end
%%%-------------------------------------------------------------------

-module(frameworkey_app).

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    PreVars = before:init(),
    ok = config:make_config(),
    ets:insert(config_table, {prevars, PreVars}),
    Routes = routing:get_routes(PreVars),
    Port = config:fetch(port),
    Dispatch = cowboy_router:compile([
        {'_', Routes}
    ]),
    {ok, _} = cowboy:start_http(my_http_listener, 100, [{port, Port}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    'frameworkey_sup':start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
