-module (tcp_handler).

-include ("./pampa_pro.hrl").

-behaviour(gen_server).
-behaviour(ranch_protocol).

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).


%% API.

start_link(Ref, Socket, Transport, Opts) ->
	{ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Socket, Transport, Opts}])}.

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
% init([]) -> {ok, undefined}.

init({Ref, Socket, Transport, _Opts = []}) ->
	io:format("tcp init pid : ~p ~n",[self()]),
	ok = ranch:accept_ack(Ref),
	ok = Transport:setopts(Socket, [{active, once}]),

	{MsgerPid,_reference} = spawn_monitor(msger,start,[self()]),
	io:format("msger id is ~p \n",[MsgerPid]),

	gen_server:enter_loop(?MODULE, [],
		#tcp_state{
					msger 		= 	MsgerPid,
					socket 		= 	Socket, 
					transport 	= 	Transport
					},
		?TCP_TIMEOUT).



handle_info({tcp, Socket, Data}, State=#tcp_state{
												msger = MsgerPid,
												socket = Socket, 
												transport = Transport})
		when byte_size(Data) > 1 ->
	io:format("handle info msger id is ~p \n",[MsgerPid]),

	io:format("received tcp data : ~p ~n",[Data]),
	io:format("tcp handle info pid : ~p ~n",[self()]),

	msger:send(?USER_SEND_MSG,Data,MsgerPid,self()),

	Transport:setopts(Socket, [{active, once}]),
	Transport:send(Socket, reverse_binary(Data)),
	{noreply, State, ?TCP_TIMEOUT};
handle_info({tcp_closed, _Socket}, State) ->
	{stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
	{stop, Reason, State};
handle_info(timeout, State) ->
	{stop, normal, State};
handle_info({?USER_RECV_MSG,Data,_From},State=#tcp_state{
												% msger = MsgerPid,
												socket = Socket, 
												transport = Transport}) ->
	io:format("tcp got msger msg : ~p ~n",[Data]),
	Transport:setopts(Socket, [{active, once}]),
	Transport:send(Socket, [<<"echo :">>,Data]),
	{noreply, State, ?TCP_TIMEOUT};
handle_info(_Info, State) ->
	{stop, normal, State}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

terminate(Reason, _State=#tcp_state{msger = MsgerPid}) ->
	% if client quit , reason is normal
	io:format("tcp terminate with reason : ~p ~n",[Reason]),

	% need send unique id but this pid =========  TODO
	msger:send(?USER_DEAD,self(),MsgerPid,self()),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% Internal.

reverse_binary(B) when is_binary(B) ->
	[list_to_binary(lists:reverse(binary_to_list(
		binary:part(B, {0, byte_size(B)-2})
	))), "\r\n"].
