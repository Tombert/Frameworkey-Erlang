-module(bodyparser).
-export([parse_body/1]).

parse_body(Req) ->
    {ok, KeyParams, Req2} = cowboy_req:body_qs(Req),
    FormParamMap = maps:from_list(KeyParams),
    QueryParamMap = maps:from_list(cowboy_req:parse_qs(Req2)),
    maps:merge(QueryParamMap, FormParamMap).

    
