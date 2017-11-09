-module(pampa_pro_app).
-behaviour(application).

-include ("./pampa_pro.hrl").

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
                % {"/echo", echo_handler, []},

                % {"/http",http_handler,[]},
                % {"/tcp",tcp_handler,[]},
                % {"/udp",udp_handler,[]},
                % {"/osc",osc_handler,[]},

                {"/ws", ws_handler,[]}
               ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, ?PORT}],
        #{env => #{dispatch => Dispatch}}
    ),
	pampa_pro_sup:start_link().

stop(_State) ->
	ok.
