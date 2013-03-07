-module(storage_web_resource).
-export([init/1, content_types_provided/2, to_json/2]).

-include_lib("webmachine/include/webmachine.hrl").

init(Function) ->
    {ok, Function}.

content_types_provided(ReqData, State) ->
    {[{"application/json", to_json}], ReqData, State}.

to_json(ReqData, get) ->
    Result = storage:get(wrq:path_info(key, ReqData)),
    {jsonize(Result), ReqData, get};

to_json(ReqData, set) ->
    Result = storage:set(wrq:path_info(key, ReqData), wrq:path_info(val, ReqData)),
    {jsonize(Result), ReqData, set};

to_json(ReqData, del) ->
    Result = storage:del(wrq:path_info(key, ReqData)),
    {jsonize(Result), ReqData, del};

to_json(ReqData, exists) ->
    Result = storage:exists(wrq:path_info(key, ReqData)),
    {jsonize(Result), ReqData, exists}.

jsonize(undefined) -> jsonize(null);
jsonize({error, Error}) -> jsonize({[{error, Error}]});
jsonize(Value) -> {ok, JSON} = json:encode(Value), JSON.
