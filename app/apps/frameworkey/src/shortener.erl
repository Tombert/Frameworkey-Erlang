-module(shortener).
-export([generate_key/1, write_to_db/1, format/1]).

generate_key(Params) ->
    Link = maps:get(<<"link">>, Params),
    <<Mac:160/integer>> = crypto:hmac(sha, <<"ZY1R/KA2ggph+9IaV79u9Eznh8DyleVN">>, Link),
    String = lists:flatten(io_lib:format("~40.16.0b", [Mac])),
    SHA = String,
    {Link, list_to_binary(SHA), maps:get(riak, Params)}.

write_to_db({Link, SHA, Riak}) ->
    Object = riakc_obj:new(<<"links">>, SHA, Link),
    riakc_pb_socket:put(Riak, Object),
    SHA.

format(SHA) ->
    #{json => #{link => SHA}}.

