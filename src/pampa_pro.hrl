-define (PORT , 9090).

-define (WS_TIMEOUT , 30000).

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
					tcpid 	= 	none,
					msger 	= 	none
					}).


-record (udp_state, {
					udpid 	= 	none,
					msger 	= 	none
					}).

