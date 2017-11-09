-define (HTTP_WEBSOCKET_PORT , 9090).
-define (TCP_PORT, 9091).
-define (WS_TIMEOUT, 30000).
-define (TCP_TIMEOUT, 10000).

-define (USER_DEAD , 'USER_DEAD').

-define (USER_SEND_MSG , 'USER_SEND_MSG').

-record (msger_state, {
						userpid 		= 		none,
						channel 		=		none,
						connection 		=		none,
						queue 			=		none,
						consumer_tag 	=		none
						}).



-record (ws_state, {
					wsid 	= 	none,
					msger 	= 	none
					}).

-record (tcp_state, {
					socket  	= 	none,
					transport 	= 	none,
					tcpid 		= 	none,
					msger 		= 	none
					}).


-record (udp_state, {
					udpid 	= 	none,
					msger 	= 	none
					}).

