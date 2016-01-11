-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [HandlerMap]) ->
    Method = cowboy_req:method(Req),
    Params = bodyparser:parse_body(Req),
    BigFunc = maybe_get_function(maps:is_key(Method, HandlerMap), HandlerMap, Method),
    Value = BigFunc(Params),
    io:format("~n~n~n~p~n~n~n~n", [Value]),
    response(Value, Req),
    {ok, Req, [HandlerMap]}.

maybe_get_function(false, _, _) ->
    fun(_) ->
            {json, #{error => <<"Not Found">>}}
    end;
maybe_get_function(true, Map, Method) ->
    maps:get(Method, Map).


response(#{header := Header, json := Data}, Req) ->
    Req2 = cowboy_req:reply(200, Header, jsx:encode(Data), Req);
response(#{json := Data}, Req) ->
    response(#{json => Data, header => [{<<"content-type">>, <<"application/json">>}]}, Req).

handle(Req, State) ->
    {ok, Reply} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
        {ok, Reply, State}.

terminate(_Req, _State) ->
    ok.
