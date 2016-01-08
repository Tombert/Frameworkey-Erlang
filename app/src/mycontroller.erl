-module(mycontroller).
-export([action/1,action2/1, action3/1]).

action(Params) ->
    Params.
action2(Blah) ->
    {json, Blah}.

action3(Blah3) ->
    {json, maps:put(howdy, <<"fart">>, Blah3)}.
