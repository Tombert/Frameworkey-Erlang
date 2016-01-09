-module(bodyparser).
-export([parse_body/1]).

parse_body(Req) ->
    ContentType = cowboy_req:parse_header(<<"content-type">>, Req),
    {ok, Body, _} = cowboy_req:body(Req),
    BodyMap = get_body_map(ContentType, Body),
    io:format("My Body, gotta work, gotta work my body ~p~n~n", [BodyMap]),
    {ok, KeyParams, Req2} = cowboy_req:body_qs(Req),
    FormParamMap = maps:from_list(KeyParams),
    QueryParamMap = maps:from_list(cowboy_req:parse_qs(Req2)),
    maps:merge(maps:merge(QueryParamMap, FormParamMap), BodyMap).

    
get_body_map({<<"application">>,<<"json">>,_}, Body) ->
    jsx:decode(Body, [return_maps]);
get_body_map(_,_) ->
    #{}.

