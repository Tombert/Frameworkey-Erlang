-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [HandlerMap]) ->
    Method = cowboy_req:method(Req),
    
    Params = bodyparser:parse_body(Req),

    BigFunc = maps:get(Method, HandlerMap),
    response(BigFunc(Params), Req),
    {ok, Req, [HandlerMap]}.

response({json, Data}, Req) ->
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        jsx:encode(Data), Req).


    

handle(Req, State) ->
    {ok, Reply} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
        {ok, Reply, State}.

terminate(_Req, _State) ->
    ok.
