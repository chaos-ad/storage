-module(storage).

-export([start/0, stop/0]).

-export([get/1, del/1, set/2, exists/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->
    start(?MODULE).

start(App) ->
    start_ok(App, application:start(App, permanent)).

stop() ->
    application:stop(?MODULE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_ok(_, ok) ->
    ok;

start_ok(_, {error, {already_started, _App}}) ->
    ok;

start_ok(App, {error, {not_started, Dep}}) when App =/= Dep ->
    ok = start(Dep),
    start(App);

start_ok(App, {error, Reason}) ->
    erlang:error({app_start_failed, App, Reason}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exists(Key) ->
    case sharded_eredis:q(["EXISTS", str(Key)]) of
        {ok, <<"1">>} -> true;
        {ok, <<"0">>} -> false;
        {error, Error} -> {error, Error}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get(Key) ->
    case sharded_eredis:q(["GET", str(Key)]) of
        {ok, Value} -> Value;
        {error, Error} -> {error, Error}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(Key, Value) ->
    case sharded_eredis:q(["SET", str(Key), str(Value)]) of
        {ok, <<"OK">>} -> ok;
        {error, Error} -> {error, Error}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

del(Key) ->
    case sharded_eredis:q(["DEL", str(Key)]) of
        {ok, Result} -> list_to_integer(binary_to_list(Result));
        {error, Error} -> {error, Error}
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal functions:

str(Value) when is_list(Value) -> Value;
str(Value) when is_atom(Value) -> atom_to_list(Value);
str(Value) when is_binary(Value) -> binary_to_list(Value);
str(Value) when is_integer(Value) -> integer_to_list(Value).
