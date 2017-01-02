%%%-------------------------------------------------------------------
%% @doc ets_buffer_test top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(ets_buffer_test_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(CHILD(I, Type, Name), {Name, {I, start_link, []}, permanent, 5000, Type, [I]}).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    _ = ets_buffer:create(my_buffer, ring, 1000),

    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    Writers = [ ?CHILD(writer, worker, list_to_atom("writer_" ++ integer_to_list(N))) || N <- lists:seq(1,100)],
    Readers = [ ?CHILD(reader, worker, list_to_atom("reader_" ++ integer_to_list(N))) || N <- lists:seq(1,100)],
    
    {ok, {SupFlags, Writers ++ Readers}}.

%%====================================================================
%% Internal functions
%%====================================================================
