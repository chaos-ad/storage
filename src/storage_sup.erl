-module(storage_sup).
-behaviour(supervisor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([start_link/0, init/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init([]) ->
    application:set_env(webmachine, webmachine_logger_module, webmachine_logger),

    {ok, { {one_for_one, 5, 10}, [
        {webmachine_mochiweb,
            {webmachine_mochiweb, start, [[
                {port,      get_env(port, 8080)},
                {ip,        get_env(host, "0.0.0.0")},
                {log_dir,   get_env(logs, "priv/logs")},
                {dispatch,  [
                    {["storage", "public", "get", key], storage_public_web_resource, get},
                    {["storage", "public", "del", key], storage_public_web_resource, del},
                    {["storage", "public", "set", key, val], storage_public_web_resource, set},
                    {["storage", "public", "exists", key], storage_public_web_resource, exists},
                    {["storage", "private", "get", gameid, userid, key], storage_private_web_resource, get},
                    {["storage", "private", "del", gameid, userid, key], storage_private_web_resource, del},
                    {["storage", "private", "set", gameid, userid, key, val], storage_private_web_resource, set},
                    {["storage", "private", "exists", gameid, userid, key], storage_private_web_resource, exists}
                ]}
            ]]},
            permanent, 5000, worker, dynamic}
    ]} }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_env(Name, Default) ->
    case application:get_env(storage, Name) of
        {ok, Env} -> Env;
        _         -> Default
    end.
