-module(health_checker).
-behaviour(gen_server).
-export([start_link/0, check_all/0, status/0, set_dependency/2]).
-export([init/1, handle_call/3, handle_cast/2]).

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

check_all() -> gen_server:call(?MODULE, check_all).
status() -> gen_server:call(?MODULE, status).
set_dependency(Name, Status) -> gen_server:call(?MODULE, {set_dep, Name, Status}).

init([]) -> {ok, #{database => ok, cache => ok}}.

handle_call(check_all, _From, State) -> {reply, State, State};
handle_call(status, _From, State) ->
    S = case lists:all(fun(V) -> V =:= ok end, maps:values(State)) of
        true -> ok;
        false -> degraded
    end,
    {reply, S, State};
handle_call({set_dep, Name, Status}, _From, State) ->
    {reply, ok, State#{Name => Status}}.

handle_cast(_Msg, State) -> {noreply, State}.
