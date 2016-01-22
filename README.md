# Frameworkey-Erlang
A web framework that allows you Unix-style piping of controller actions. What you feel in your pants is a okay. That is what we call a nerd boner.

## Why?

Why not?

## No really, why?

Because when doing web-development with a lot of endpoints, there tends to be a ton of nesting-of-functions, and consequently, a ton of "copy-paste, and change one line" for different endpoints.  What I want is to allow small, reusable, composable functions that can be arbitrarily glued together.

## How does it work?

### Routing
That's easy.  In the `routes.json`:

```
{
  "METHOD /endpoint": "mycontroller.action mycontroller.action2"
}
```

`mycontroller` in this case is just a vanilla erlang module with the functions `action/1` and `action/2` exported.  Here's what it can look like:

```
-module(mycontroller).
-export([action/1,action2/1]).

action(Params) ->
    Params.
action2(Blah) ->
    #{ json => Blah, header => #{code => 201, data =>[{<<"content-type">>,<<"application/json">>}]}}.


```

These functions can be chained ad-nauseum.  If you wanted to have fifty actions handle an action, be my guest.  Just make sure that the last action returns a map with the key `json`. 


### Permissions/ACL
The specifics of the API are liable to change, but the documentation is as follows.

Permissions are specified in the `priv/policies.json` file. Currently this is unchangable. The file should look like this:

```
{
  "mycontroller":{
    "action": ["auth", "admin"],
    "*": "auth"
  }
}
```
You can specify as many policies for each action as you'd like, and are run in the order in which they appear in the array (you can omit the array if you only want to run one policy). If any policies return `false`, none of the actions for the endpoint will be run, and a `403` will be sent to the client.

The `"*"` is the "fallback action".  If a policy is not defined for the particular action that's about to be run, it "falls back" to the `*` as a sort of default permission.

#### Defining Policies
A policy may look something like this:

```
-module(auth).
-export([check/1]).

check(Params) ->
  Username = maps:get(<<"username">>, Params),
  Password= maps:get(<<"password">>, Params),
  Result = case db:lookupUser(Username, Password) of
    {error, nouser} -> false;
    {ok, User} -> true
  end,
  Result. 

```

You can probably make this look more elegant with cooler pattern matching and whatnot, but here's the criteria you need to know:
- A policy needs to have a `check/1` function exported.
- The argument that will be fed into `check/1` will be a map with all the params from the request.
- You return `true` or `false` depending on whether or not you want to grant access. 


## What tech is powering this? 

Besides my amazingly clever ingenuity, Frameworkey is powered by the amazingly wonderful [Cowboy](http://ninenines.eu/docs/en/cowboy/HEAD/guide/) server.  I use Sync so that I don't have to constantly reload stuff.  It's not hard. 

## What version of Erlang does this support?

I'm not sure, but I make pretty liberal use of maps, so at least Erlang 17.  I develop using Erlang 18.   
