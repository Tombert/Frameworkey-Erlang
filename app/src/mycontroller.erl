-module(mycontroller).
-export([action/1,action2/1, action3/1]).

action(Params) ->
    Params.
action2(Blah) ->
    #{ json => Blah, header => #{code => 201, data =>[{<<"content-type">>,<<"application/json">>}]}}.

action3(Blah3) ->
    Yo = maps:put(howdy, <<"fart">>, Blah3),
    #{ json => Yo, header => #{code => 201, data =>[{<<"content-type">>,<<"application/json">>}]}}.

