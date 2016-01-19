-module(policies).
-export([get_policies/0]).

%% check(Params) ->
%%   [{_, Policies}] = ets:lookup(policy_table, policies),
  
%%   runPolicies(Params,  )  

get_policies() ->
    ets:new(policy_table, [named_table, protected,set, {keypos, 1}]),
    {ok, JSON} = file:read_file(code:priv_dir(frameworkey) ++ "/policies.json"),
    Policies = jsx:decode(JSON),
    RealPolicies = lists:map(fun atomize_controllers/1, Policies),
    Policies = maps:from_list(RealPolicies),
    ets:insert(policy_table, {policies, Policies}).


atomize_controllers({Controller, Actions}) ->    
    Con = binary_to_atom(Controller, unicode),
    ActAtoms = lists:map(fun atomize_actions/1, Actions),
    {Con, ActAtoms}.

atomize_actions({Action, Policies}) ->
    Act = binary_to_atom(Action, unicode),
    PolicyAtoms = lists:map(fun(I) -> binary_to_atom(I, unicode) end, Policies),
    {Act, PolicyAtoms}.

runPolicies(Params, [Policy | Policies], true) ->
    Result = Policy:check(Params),
    runPolicies(Params, Policies, Result);
runPolicies(_, [], true) ->
    true;
runPolicies(_, _, false) ->
    false.
