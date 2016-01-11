# Frameworkey-Erlang
A web framework that (theretically) allows you to have Unix-style pipes for controller actions.

## Why?

Why not?

## No really, why?

Because when doing web-development with a lot of platforms, there tends to be a ton of nesting-of-functions, and consequently, a ton of "copy-paste, and change one line" for different endpoints.  What I want is to allow small, reusable, composable functions that can be arbitrarily glued together.

## How does it work?

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
