-module(ws_handler).
-behavior(cowboy_handler).

-include ("./pampa_pro.hrl").


-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).


init(Req, _State) ->
	% io:format("req is ~p \n",[Req]),
	WsId = cowboy_req:header(<<"sec-websocket-key">>, Req),
	% io:format("ws id is ~p \n",[WsId]),

	{cowboy_websocket,Req,#ws_state{wsid = WsId},#{idle_timeout => ?WS_TIMEOUT}}.
	% handle Websocket subprotocols ============================
	% case cowboy_req:parse_header(<<"sec-websocket-protocol">>, Req) of
 %        undefined ->
 %            {cowboy_websocket, Req, State,#{idle_timeout => 300000}};
 %        Subprotocols ->
 %            case lists:keymember(<<"mqtt">>, 1, Subprotocols) of
 %                true ->
 %                    Req1 = cowboy_req:set_resp_header(<<"sec-websocket-protocol">>,
 %                        <<"mqtt">>, Req),
 %                    {cowboy_websocket, Req1, State,#{idle_timeout => 300000}};
 %                false ->
 %                    {stop, Req, State}
 %            end
 %    end.


websocket_init(State) ->
	io:format("ws state is ~p \n",[State]),

 	% init msger of rabbitmq-server
	{MsgerPid,_reference} = spawn_monitor(msger,start,[self()]),
	% io:format("msger id is ~p \n",[MsgerPid]),
	State1 = State#ws_state{msger = MsgerPid},

	{reply,{text,[<<"ws_id:">>,State#ws_state.wsid]},State1,hibernate}.






% handle websocket binary data arrived ==========================  TODO
% websocket_handle({binary,Binary},State) ->

% 	{ok,State,hibernate};


websocket_handle({text,Text},State) ->
	% WsId = State#ws_state.wsid,
	MsgerPid = State#ws_state.msger,
	% io:format("frame is ~p from wsid : ~p \n",[Text,WsId]),
	msger:send(?USER_SEND_MSG,Text,MsgerPid,self()),
	{reply,{text,Text},State,hibernate};
websocket_handle({binary,Binary},State) ->
	% WsId = State#ws_state.wsid,
	MsgerPid = State#ws_state.msger,
	% io:format("frame is ~p from wsid : ~p \n",[Text,WsId]),
	msger:send(?USER_SEND_MSG,Binary,MsgerPid,self()),
	{reply,{binary,Binary},State,hibernate};
websocket_handle(_Frame,State) ->
	{ok,State,hibernate}.


% for websocket_info/2
% msger message will handle here
websocket_info({'RECV',Data,_From},State) ->
	% io:format("received msger data : ~p  from : ~p \n ",[Data,From]),
	% {ok,State,hibernate};
	{reply,{text,Data},State,hibernate};

websocket_info({log,Text},State) ->
	{reply,{text,Text},State,hibernate};
websocket_info(Info,State) ->
	io:format("on other info : ~p ~n ",[Info]),
	{ok,State,hibernate}.



terminate(Reason, PartialReq, State) -> 
	io:format("reason : ~p , partialreq : ~p , State : ~p ~n",[Reason,PartialReq,State]),
	MsgerPid = State#ws_state.msger,
	msger:send(?USER_DEAD,State#ws_state.wsid,MsgerPid,self()),
	receive
		{'RECV',Payload,MsgerPid} ->
			io:format("normal exit on data : ~p with msgerid : ~p ~n",[Payload,MsgerPid]),
			ok;
		Error ->
			io:format("error on websocket terminate : ~p ~n",[Error]),
		ok
	end.














% websocket_handle({text,Text},State) ->
% 	io:format("frame is ~p \n",[Text]),
% 	{reply,{text,<<"hi there">>},State};
% websocket_handle(_Frame,State) ->
% 	{ok,State}.


% % for websocket_info/2
% websocket_info({log,Text},State) ->
% 	{reply,{text,Text},State};
% websocket_info(_Info,State) ->
% 	{ok,State}.











 %    Req = cowboy_req:reply(200,
 %        #{<<"content-type">> => <<"text/plain">>},
 %        <<"Hello Erlang!">>,
 %        Req0),
	% {ok, Req, State}.
