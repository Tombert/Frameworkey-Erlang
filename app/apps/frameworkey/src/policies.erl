-module(policies).
-export([get_policies/0, check/3]).



% This is run on-request to check the permission of doing something. 
check(Params, Controller, Action) ->
    % Grab the Policies map out of memory, which should have been 
    % stored there. 
    [{_, Policies}] = ets:lookup(policy_table, policies),

    % Lookup the controller we need to check inside the map. 
    ControllerPolicy = maps:get(Controller, Policies),

    % We're *not* storing these actions in a sub-map
    % Consequently we need to use a list-keyfind functoin to get the 
    % action we want.  If it can't find what we need, it shoudl return false. 
    MyActions = maybe_find_actions(lists:keyfind(Action, 1, ControllerPolicy), ControllerPolicy),
    run_policies(Params,  MyActions, true).
    


% This a simple function to give a "default" value
% to the actions. If we get a "false" in a keyfind above, 
% we fall back on the '*' in the config JSON. We also defensively
% convert to a list to make sure we can happily loop over it. 
maybe_find_actions(false, ControllerPolicy) ->
    {'*', A} = lists:keyfind('*', 1, ControllerPolicy),
    make_list(A);
maybe_find_actions({_, A}, _) ->
    make_list(A).


% This is a helper function to convert a non-list
% into a list.  This is cheaper than doing a flatten([A]).
make_list(A) when is_list(A) ->
    A;
make_list(A)  ->
    [A].



% This should run, and grab and parse all the policies out of the policies.json file.
% Then it puts these findings in ETS, much to my chagrin. 
get_policies() ->
    ets:new(policy_table, [named_table, protected,set, {keypos, 1}]),
    {ok, JSON} = file:read_file(code:priv_dir(frameworkey) ++ "/policies.json"),
    Policies = jsx:decode(JSON),
    RealPolicies = lists:map(fun atomize_controllers/1, Policies),

    PoliciesMap = maps:from_list(RealPolicies),

    ets:insert(policy_table, {policies, PoliciesMap}).



% This is used to convert policies to a *callable* controller atom. 
% We also need to loop through the actions inside the controller. 
atomize_controllers({Controller, Actions}) ->    
    Con = binary_to_atom(Controller, unicode),
    ActAtoms = lists:map(fun atomize_actions/1, Actions),
    {Con, ActAtoms}.


% This converts the actions to callable atoms, and loops through the 
% policies and converts them to something callable as well. 
atomize_actions({Action, Policies}) ->
    Act = binary_to_atom(Action, unicode),
    PoliciesList = make_list(Policies),
    PolicyAtoms = lists:map(fun(I) -> binary_to_atom(I, unicode) end, PoliciesList),
    {Act, PolicyAtoms}.


% We're looping through the policies until we get one that returns false. 
% If we get a false, then there's no reason to keep running the policies, as 
% we already know they don't have permission. 
run_policies(_, [], true) ->
    true;
run_policies(Params, [Policy | Policies], true) ->
    Result = Policy:check(Params),
    run_policies(Params, Policies, Result);
run_policies(_, _, false) ->
    false.
