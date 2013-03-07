-module(storage_sup).
-behaviour(supervisor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([start_link/0, init/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(CHILD(I), {I, {I, start_link, []}, permanent, 60000, worker, [I]}).
-define(CHILD(I, Args), {I, {I, start_link, Args}, permanent, 60000, worker, [I]}).
-define(CHILD(I, Args, Role), {I, {I, start_link, Args}, permanent, 60000, Role, [I]}).

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
                    {["storage", "get", key], storage_web_resource, get},
                    {["storage", "del", key], storage_web_resource, del},
                    {["storage", "set", key, val], storage_web_resource, set},
                    {["storage", "exists", key], storage_web_resource, exists}
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
