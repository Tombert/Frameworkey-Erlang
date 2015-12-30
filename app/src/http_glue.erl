-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [Method, BigFunc]) ->
    io:format("~p~n~n~n", [cowboy_req:path(Req)]),
    
    % This is an assertion; I want to make sure that the method matches
    io:format("Method: ~p~n~n~n", [Method]),
    io:format("~p~n~n~n", [cowboy_req:method(Req)]),
    Method = cowboy_req:method(Req),
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/html">>}],
        <<"Hello Erlang!\n">>, Req),
        {ok, Req2, [Method, BigFunc]}.


handle(Req, State) ->
    {ok, Reply} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
        {ok, Reply, State}.

terminate(_Req, _State) ->
    ok.
