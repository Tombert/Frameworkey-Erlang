-module(bodyparser).
-export([parse_body/1]).

parse_body(Req) ->
    ContentType = cowboy_req:parse_header(<<"content-type">>, Req),
    BodyMap = get_body_map(ContentType, Req),
    QueryParamMap = maps:from_list(cowboy_req:parse_qs(Req)),
    Bindings = get_route_params(Req),
    maps:merge(maps:merge(QueryParamMap, Bindings), BodyMap).

get_route_params(Req) ->
    Bindings = cowboy_req:bindings(Req),
    RealParams = lists:map(fun({Key, Value}) ->  {list_to_binary(atom_to_list(Key)), Value} end, Bindings),
    maps:from_list(RealParams).

get_body_map({<<"application">>,<<"json">>,_}, Req) ->
    {ok, Body, _} = cowboy_req:body(Req),
    jsx:decode(Body, [return_maps]);
get_body_map({<<"application">>,<<"x-www-form-urlencoded">>,_}, Req) ->
    {ok, KeyParams, _} = cowboy_req:body_qs(Req),
    maps:from_list(KeyParams);
get_body_map({<<"multipart">>,<<"form-data">>,_},Req) ->
    Things = multipart(Req),
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
                                 {Req3, NewStuff};
                             {file, _FieldName, _Filename, _CType, _CTransferEncoding} ->

                                 {ReqP, FileName} = stream_file(Req2, binary_to_list(_Filename)),
                                 NewStuff = [ {_FieldName, list_to_binary(FileName)} | Stuff],
                                 {ReqP, NewStuff}
                                     
            end,
            multipart(Req4, NS);
        {done, Req2} ->
            Stuff
    end.
 
stream_file(Req, FileName) ->
    DLDir = config:fetch(download_dir),
    FN = DLDir ++ FileName,
    case cowboy_req:part_body(Req) of
        {ok, _Body, Req2} ->
            file:write_file(DLDir ++ FileName, _Body, [append]),
            {Req2, FN};
        {more, _Body, Req2} ->
            file:write_file(DLDir ++ FileName, _Body,[append]),
            stream_file(Req2, FN)
    end.
