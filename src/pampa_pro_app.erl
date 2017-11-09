-module(pampa_pro_app).
-behaviour(application).
-include ("../deps/amqp_client/include/amqp_client.hrl").

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	% {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok, Connection} = amqp_connection:start(#amqp_params_direct{}),
	 {ok, Channel} = amqp_connection:open_channel(Connection),
	io:format("amqp channel is ~p ~n",[Channel]),

	pampa_pro_sup:start_link().

stop(_State) ->
	ok.
