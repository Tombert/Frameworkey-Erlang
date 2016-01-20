-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [HandlerMap]) ->
    Method = cowboy_req:method(Req),
    Params = bodyparser:parse_body(Req),
    BigFunc = maps:get(Method, HandlerMap, fun(_) -> {json, #{error => <<"Not Found">>}} end),
    Value = BigFunc(Params),
    response(Value, Req),
    {ok, Req, [HandlerMap]}.


response(#{header := Header, json := Data}, Req) ->
    #{ code := Code, data := RealHeader }= make_real_header(Header),
    Req2 = cowboy_req:reply(Code, RealHeader, jsx:encode(Data), Req);
response(#{json := Data}, Req) ->
    response(#{json => Data, header => #{ code => 200, data => [{<<"content-type">>, <<"application/json">>}]}}, Req).


make_real_header(#{code := Code, data := Data}) ->
    #{code => Code, data => Data};
make_real_header(#{data := Data}) ->
    #{code => 200, data => Data};
make_real_header(Headers) when is_list(Headers) ->
    #{code => 200, data => Headers}.

handle(Req, State) ->
    {ok, Reply} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
        {ok, Reply, State}.

terminate(_Req, _State) ->
    ok.
