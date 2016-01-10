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
get_body_map({<<"multipart">>,<<"form-data">>,_},{_, Req}) ->
    Things = multipart(Req),
    io:format("~n~n~n~nThings ~p~n~n~n",[Things]),
    maps:from_list(Things);
get_body_map(_,_) ->
    #{}.

multipart(Req)->
    multipart(Req, []).


multipart(Req, Stuff) ->
    case cowboy_req:part(Req) of
        {ok, Headers, Req2} ->
            
            {Req4, NS} = case cow_multipart:form_data(Headers) of
                       {data, _FieldName} ->
                           
                                       {ok, _Body, Req3} = cowboy_req:part_body(Req2),
                                       NewStuff = [ {_FieldName, _Body} | Stuff],
                                       {Req3, NewStuff}                                       
            end,
            multipart(Req4, NS);
        {done, Req2} ->
            Stuff
    end.
 
stream_file(Req) ->
    case cowboy_req:part_body(Req) of
        {ok, _Body, Req2} ->
            Req2;
        {more, _Body, Req2} ->
            stream_file(Req2)
    end.
