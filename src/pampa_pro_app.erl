-module(pampa_pro_app).
-behaviour(application).

-include ("./pampa_pro.hrl").

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
                % {"/echo", echo_handler, []},

                {"/http",http_handler,[]},
                % {"/udp",udp_handler,[]},
                % {"/osc",osc_handler,[]},

                {"/ws", ws_handler,[]}
               ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, ?HTTP_WEBSOCKET_PORT}],
        #{env => #{dispatch => Dispatch}}
    ),

    % tcp handler 
    {ok, _} = ranch:start_listener(my_tcp_listener,
        ranch_tcp, 
        [{port, ?TCP_PORT}],
        tcp_handler, 
        []
	),
	pampa_pro_sup:start_link().

stop(_State) ->
	ok.
