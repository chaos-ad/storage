-module(storage).

-export([start/0, stop/0]).

-export([get/1, get/3]).
-export([del/1, del/3]).
-export([set/2, set/4]).
-export([exists/1, exists/3]).

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
        {error, Error} -> error(Error)
    end.

exists(GameID, UserID, Key) ->
    exists(key(GameID, UserID, Key)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get(Key) ->
    case sharded_eredis:q(["GET", str(Key)]) of
        {ok, Result} -> Result;
        {error, Error} -> error(Error)
    end.

get(GameID, UserID, Key) ->
    ?MODULE:get(key(GameID, UserID, Key)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(Key, Value) ->
    case sharded_eredis:q(["SET", str(Key), str(Value)]) of
        {ok, <<"OK">>} -> ok;
        {error, Error} -> error(Error)
    end.

set(GameID, UserID, Key, Value) ->
    ?MODULE:set(key(GameID, UserID, Key), Value).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

del(Key) ->
    case sharded_eredis:q(["DEL", str(Key)]) of
        {ok, Result} -> list_to_integer(binary_to_list(Result));
        {error, Error} -> error(Error)
    end.

del(GameID, UserID, Key) ->
    ?MODULE:del(key(GameID, UserID, Key)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal functions:

key(GameID, UserID, Key) ->
    string:join([str(GameID), str(UserID), str(Key)], ".").

str(Value) when is_list(Value) -> Value;
str(Value) when is_atom(Value) -> atom_to_list(Value);
str(Value) when is_binary(Value) -> binary_to_list(Value);
str(Value) when is_integer(Value) -> integer_to_list(Value).
