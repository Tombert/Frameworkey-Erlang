-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [HandlerMap]) ->
    Method = cowboy_req:method(Req),

    BigFunc = maps:get(Method, HandlerMap),
    io:format("~p~n~n~n", [cowboy_req:method(Req)]),
    Method = cowboy_req:method(Req),
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/html">>}],
        <<"Hello Erlang!\n">>, Req),
        {ok, Req2, [HandlerMap]}.


handle(Req, State) ->
    {ok, Reply} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
        {ok, Reply, State}.

terminate(_Req, _State) ->
    ok.
