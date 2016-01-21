-module(policies).
-export([get_policies/0, check/3]).

check(Params, Controller, Action) ->
    [{_, Policies}] = ets:lookup(policy_table, policies),
    ControllerPolicy = maps:get(Controller, Policies),
    io:format("~n~n~n~n~n~n~n~nController:~p~n~n~n~n~n Action:~p~n~n~n~nControllerPolicy:~p~n~n~n", [Controller, Action, ControllerPolicy]),
    MyActions = maybe_find_actions(lists:keyfind(Action, 1, ControllerPolicy), ControllerPolicy),
    run_policies(Params,  MyActions, true).
    
maybe_find_actions(false, ControllerPolicy) ->
    {'*', A} = lists:keyfind('*', 1, ControllerPolicy),
    A;
maybe_find_actions({_, A}, _) ->
    A.

get_policies() ->
    ets:new(policy_table, [named_table, protected,set, {keypos, 1}]),
    {ok, JSON} = file:read_file(code:priv_dir(frameworkey) ++ "/policies.json"),
    Policies = jsx:decode(JSON),
    RealPolicies = lists:map(fun atomize_controllers/1, Policies),
    io:format("~n~n~n~nPolicies:~p~n~n~n", [RealPolicies]),
    PoliciesMap = maps:from_list(RealPolicies),
    io:format("~n~n~n~nPoliciesMap:~p~n~n~n", [PoliciesMap]),
    ets:insert(policy_table, {policies, PoliciesMap}).


atomize_controllers({Controller, Actions}) ->    
    Con = binary_to_atom(Controller, unicode),
    ActAtoms = lists:map(fun atomize_actions/1, Actions),
    {Con, ActAtoms}.

atomize_actions({Action, Policies}) ->
    Act = binary_to_atom(Action, unicode),
    PolicyAtoms = lists:map(fun(I) -> binary_to_atom(I, unicode) end, Policies),
    {Act, PolicyAtoms}.


run_policies(_, [], true) ->
    true;
run_policies(Params, [Policy | Policies], true) ->
    Result = Policy:check(Params),
    run_policies(Params, Policies, Result);
run_policies(_, _, false) ->
    false.
