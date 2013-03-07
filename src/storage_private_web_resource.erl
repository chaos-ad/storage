-module(storage_private_web_resource).
-export([init/1, content_types_provided/2, to_json/2]).

-include_lib("webmachine/include/webmachine.hrl").

init(Function) ->
    {ok, Function}.

content_types_provided(ReqData, State) ->
    {[{"application/json", to_json}], ReqData, State}.

to_json(ReqData, get) ->
    {jsonize(storage:get(key(ReqData))), ReqData, get};

to_json(ReqData, set) ->
    {jsonize(storage:set(key(ReqData), val(ReqData))), ReqData, set};

to_json(ReqData, del) ->
    {jsonize(storage:del(key(ReqData))), ReqData, del};

to_json(ReqData, exists) ->
    {jsonize(storage:exists(key(ReqData))), ReqData, exists}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal functions:

jsonize(undefined) -> jsonize(null);
jsonize({error, Error}) -> jsonize({[{error, Error}]});
jsonize(Value) -> {ok, JSON} = json:encode(Value), JSON.

key(ReqData) ->
    "l." ++ wrq:path_info(gameid, ReqData) ++
     "." ++ wrq:path_info(userid, ReqData) ++
     "." ++ wrq:path_info(key, ReqData).

val(ReqData) ->
    wrq:path_info(val, ReqData).
