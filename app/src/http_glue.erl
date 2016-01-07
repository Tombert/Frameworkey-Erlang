-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [HandlerMap]) ->
    Method = cowboy_req:method(Req),
    
%    {ok, Blah, Req2} = cowboy_req:body_qs(Req),
    %{ok, Blah, Req2} = cowboy_req:body_qs(Req),
    Blah = bodyparser:parse_body(Req),
    io:format("Fart ~n~n~n~p~n~n~n", [Blah]),

    BigFunc = maps:get(Method, HandlerMap),

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
