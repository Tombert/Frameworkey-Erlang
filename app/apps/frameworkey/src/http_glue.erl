-module(http_glue).
-export([init/2, handle/2, terminate/2]).


init(Req, [HandlerMap]) ->
    Method = cowboy_req:method(Req),
    Params = bodyparser:parse_body(Req),
    {BigFunc, ModActAtoms} = maps:get(Method, HandlerMap, {fun(_) -> {json, #{error => <<"Not Found">>}} end, []}),
    Results = lists:map(fun({Controller, Action}) -> policies:check(Params, Controller, Action) end, ModActAtoms), 
    IsNotAllowed = lists:member(false, Results),
    RealFunc = authorizedFunc(IsNotAllowed, BigFunc),
    Value = RealFunc(Params),
    response(Value, Req),
    {ok, Req, [HandlerMap]}.



% This is a basic helper function because of my refusal to use a case statement. 
% basically, if a "false" exists in the list, give back an error function. Otherwise, 
% return back the original function. 
authorizedFunc(true, _) -> 
    fun(_) ->
            #{json => #{error => <<"Not Authorized">>}, header => #{code => 403, data => []}}
    end;
authorizedFunc(false, BigFunc) -> 
    BigFunc.nn

% This function first normalizes the header and data, and then sends
% back a response to the client. 
response(#{header := Header, json := Data}, Req) ->
    #{ code := Code, data := RealHeader }= make_real_header(Header),
    Req2 = cowboy_req:reply(Code, RealHeader, jsx:encode(Data), Req);
response(#{json := Data}, Req) ->
    response(#{json => Data, header => #{ code => 200, data => [{<<"content-type">>, <<"application/json">>}]}}, Req).


% This function takes in a header map, and normalizes
% it to make sure it's formatted correctly
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
