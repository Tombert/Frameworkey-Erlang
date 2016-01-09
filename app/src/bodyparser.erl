-module(bodyparser).
-export([parse_body/1]).

parse_body(Req) ->
    ContentType = cowboy_req:parse_header(<<"content-type">>, Req),
    {ok, Body, _} = cowboy_req:body(Req),
    BodyMap = get_body_map(ContentType, {Body, Req}),
    io:format("My Body, gotta work, gotta work my body ~p~n~n", [ContentType]),

    QueryParamMap = maps:from_list(cowboy_req:parse_qs(Req)),
    maps:merge(QueryParamMap, BodyMap).

    
get_body_map({<<"application">>,<<"json">>,_}, {Body, _}) ->
    jsx:decode(Body, [return_maps]);
get_body_map({<<"application">>,<<"x-www-form-urlencoded">>,_},{_, Req}) ->
    {ok, KeyParams, _} = cowboy_req:body_qs(Req),
    maps:from_list(KeyParams);

get_body_map(_,_) ->
    #{}.

