-module(before). 
-export([init/0]).

init() ->
    {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
    #{riak => Pid}.
