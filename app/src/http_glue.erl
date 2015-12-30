-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, Opts) ->
    io:format("~p~n~n~n", [Opts]),
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/html">>}],
        <<"Hello Erlang!\n">>, Req),
        {ok, Req2, Opts}.


handle(Req, State) ->
    {ok, Reply} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
        {ok, Reply, State}.

terminate(_Req, _State) ->
    ok.
