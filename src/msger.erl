-module (msger).

-include ("../deps/amqp_client/include/amqp_client.hrl").
-include ("./pampa_pro.hrl").

-export ([start/1]).
-export ([send/4]).

start(UserPid) ->
    % io:format("msger for pid : ~p \n",[UserPid]),
    % {ok, Connection} = amqp_connection:start(#amqp_params_direct{virtual_host = "/"}),
    {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
    % {ok, Connection} = amqp_connection:start(#amqp_params_direct{}),

    {ok, Channel} = amqp_connection:open_channel(Connection),

    E = #'exchange.declare'{exchange = <<"hello1">>,type = <<"fanout">>},
    #'exchange.declare_ok'{} = amqp_channel:call(Channel,E),

    % Q = #'queue.declare'{queue = <<"hello1">>},
    #'queue.declare_ok'{queue = Q} = amqp_channel:call(Channel,#'queue.declare'{}),
    % io:format("declared queue ~p ~n",[Q]),
    Sub = #'basic.consume'{queue = Q,no_ack = true},
    % io:format("prepared sub ~p ~n",[Sub]),

    #'basic.consume_ok'{consumer_tag = Tag} = amqp_channel:subscribe(Channel,Sub,self()),
    % io:format("declared sub with tag ~p for channel : ~p connection : ~p ~n",[Tag,Channel,Connection]),


    Binding = #'queue.bind'{queue = Q,
                            exchange = <<"hello1">>
                            },
    % io:format("prepared binding ~p ~n",[Binding]),
    #'queue.bind_ok'{} = amqp_channel:call(Channel,Binding),

    State = #msger_state{
                userpid         =       UserPid,
                queue           =       Q, 
                channel         =       Channel, 
                connection      =       Connection, 
                consumer_tag    =       Tag},
    % % prepared for enter loop
    loop(State).

loop(State) ->
    % io:format("msger id : ~p in loop for wspic : ~p \n",[self(),State#msger_state.wspid]),
    receive
        % subscription cancelled , this exit loop normal or clean something fro ws pid ================  TODO
        #'basic.cancel_ok'{} ->
            ok;
        % maybe not recv this because set no_ack to true
        % {#'basic.deliver'{delivery_tag = DeliveryTag}, #amqp_msg{payload = Body}} ->
        %     io:format(" [x] Received ~p need ack with tage ~p ~n", [Body,DeliveryTag]),
        %     UserPid ! {'RECV',Body,self()},
        %     loop(Channel,Tag,UserPid);

        {#'basic.deliver'{},#amqp_msg{payload = Payload}} ->
            io:format(" [x] Received ~p~n", [Payload]),
            State#msger_state.userpid ! {'RECV',Payload,self()},
            loop(State);

        {?USER_SEND_MSG,Data,_UserPid} ->
            % io:format("send data : ~p for ws : ~p \n",[Data,UserPid]),
    		amqp_channel:cast(State#msger_state.channel,
                                #'basic.publish'{exchange = <<"hello1">>}, 
                                #amqp_msg{payload = Data}),
            loop(State); 
        {?USER_DEAD,DeadWsId,_UserPid} ->
            amqp_channel:cast(State#msger_state.channel,
                                #'basic.publish'{exchange = <<"hello1">>}, 
                                #amqp_msg{payload = [<<"dead_id:">>,DeadWsId]}),

            loop(State);
        _Other ->
            % io:format("msger received unknown messages"),
            loop(State)

    end.


send(Action,Data,MsgerPid,From) ->
    MsgerPid ! {Action,Data,From}.
