-module (http_handler).
-include ("./pampa_pro.hrl").

-export ([init/2]).


init(Req, State) ->

	% parse params ========
	% #{
	% 	% <<"nonce">> 			:= 		Nonce,
	% 	% <<"timestamp">> 		:= 		Timestamp,
	% 	% not use following yet ==========
	% 	% <<"openid">> 			:= 		OpenID,
	% 	% <<"encrypt_type">> 	:= 		EncryptType,
	% 	% <<"msg_signature">> 	:= 		MsgSignature,
	% 	% <<"signature">> 		:= 		Signature

	% } = 
	% 	maps:from_list(cowboy_req:parse_qs(Req)),


	Method = cowboy_req:method(Req),
	handle(Method,Req,State).


handle(<<"GET">>,Req,State) ->
	#{
		% <<"nonce">> 			:= 		Nonce,
		% <<"timestamp">> 		:= 		Timestamp,
		% not use following yet ==========
		% <<"openid">> 			:= 		OpenID,
		% <<"encrypt_type">> 	:= 		EncryptType,
		% <<"msg_signature">> 	:= 		MsgSignature,
		% <<"signature">> 		:= 		Signature
		<<"echo">> 	:= 	Echo


	} = 
		maps:from_list(cowboy_req:parse_qs(Req)),


	Req1 = cowboy_req:reply(
			200,
			#{<<"content-type">> => <<"text/plain">>},
			Echo,
			Req
			),
	{ok,Req1,State};


handle(<<"POST">>,Req,State) ->
	Echo = <<"post echo">>,
	Req1 = cowboy_req:reply(
		200,
		#{<<"content-type">> => <<"text/plain">>},
		Echo,
		Req
		),
	{ok,Req1,State}.


% =================================  


% -module(pampa_api_handler).
% -behavior(cowboy_handler).
% -include("../include/mylog.hrl").
% -include("../include/config.hrl").
% -include_lib("xmerl/include/xmerl.hrl").

% -export([init/2]).

% init(Req, State) ->
% 	% not work yet =================  TODO 
% 	?myPrint("init state is",State),

% 	% parse params ========
% 	#{
% 		<<"nonce">> 			:= 		Nonce,
% 		<<"timestamp">> 		:= 		Timestamp,
% 		% not use following yet ==========
% 		% <<"openid">> 			:= 		OpenID,
% 		% <<"encrypt_type">> 	:= 		EncryptType,
% 		% <<"msg_signature">> 	:= 		MsgSignature,
% 		<<"signature">> 		:= 		Signature

% 	} = 
% 		maps:from_list(cowboy_req:parse_qs(Req)),
	

% 	Check = wechat_utils:check(binary_to_list(Signature), binary_to_list(Timestamp), binary_to_list(Nonce)),
% 	% ?myPrint("check",Check),

% 	if
% 		Check == false ->
% 			{error,Req,State};
% 		true ->
% 			Method = cowboy_req:method(Req),
% 			handle(Method,Req,State)
% 	end.


% % handle(<<"GET">>,Req,State) ->
% % 	Req1 = cowboy_req:reply(
% % 		200,
% % 		#{<<"content-type">> => <<"text/plain">>},
% % 		<<"get echo">>,
% % 		Req
% % 		),
% % 	{ok,Req1,State};

% handle(<<"GET">>,Req,State) ->
% 	Qs1 = cowboy_req:parse_qs(Req),
% 	{_,Echo} = lists:nth(2,Qs1),
% 	Req1 = cowboy_req:reply(
% 			200,
% 			#{<<"content-type">> => <<"text/plain">>},
% 			Echo,
% 			Req
% 			),
% 	{ok,Req1,State};

% handle(<<"POST">>,Req,State) ->
% 	% ?myPrint("post req",Req),
% 	{ok, Body, Req1} = cowboy_req:read_body(Req),
% 	RootElement = exomler:decode(Body),

% 	{_Tag, _Attrs, Content} = RootElement,
% 	% ?myPrint("content",Content),
% 	% for later reply use ======================
% 	% ?myPrint("xml tag",Tag),
% 	% ?myPrint("xml attrs",Attrs),
% 	% remove [] between K,V made by exomler ====================== 
% 	% decrypt not yet TODO ===============
% 	Content1 = [{K,V} || {K,_emptylist,V} <- Content],
% 	Content2 = maps:from_list(Content1),
% 	% ?myPrint("Content",Content2),

% 	[MsgType] = maps:get(<<"MsgType">>,Content2),
% 	?myPrint("MsgType",MsgType),

% 	% [Encrypt] = maps:get(<<"Encrypt">>,Content2),

% 	% ?myPrint("Encrypt",Encrypt),
% 	% =============================================
% 	% pass token into handler for get resource from wechat server 
% 	% back with new token anyway ,changed or not
% 	Token0 = maps:get(?STATE_TOKEN,State),

% 	case MsgType of
% 		<<"text">>  ->
% 			% {Token1,_ResData} = utake1_itake1:handle('TEXT',Content2,Token0),
% 			[CreateTime] 		= 		maps:get(<<"CreateTime">>,Content2),
% 			[ToUserName]		=		maps:get(<<"ToUserName">>,Content2),
% 			[FromUserName]		=		maps:get(<<"FromUserName">>,Content2),
% 			% [MsgId]				= 		maps:get(<<"MsgId">>,Content2),
% 			Reply0 = [
% 				<<"<xml>">>,
% 				<<"<ToUserName><![CDATA[">>,ToUserName,<<"]]></ToUserName>">>,
% 				<<"<FromUserName><![CDATA[">>,FromUserName,<<"]]></FromUserName>">>,
% 				<<"<CreateTime>">>,CreateTime,<<"</CreateTime>">>,
% 				<<"<MsgType><![CDATA[">>,MsgType,<<"]]></MsgType>">>,
% 				<<"<Content><![CDATA[">>,<<"hello">>,<<"]]></Content>">>,
% 				% <<"<MsgId><![CDATA[">>,MsgId,<<"]]></MsgId>">>,
% 				<<"</xml>">>
% 			],
% 			Reply1 = iolist_to_binary(Reply0),
% 			?myPrint("text reply",Reply1),
% 			Req2 = cowboy_req:reply(
% 					200,
% 					#{<<"content-type">> => <<"application/xml">>},
% 					% Reply1,
% 					<<"">>,
% 					Req1
% 				),


% 			{ok,Req2,State#{?STATE_TOKEN := <<"">>}};


% 		<<"video">> ->
% 			{Token1,_ResData} = utake1_itake1:handle('VIDEO',Content2,Token0),
% 			% ?myPrint("video reply data",length(ResData)),
% 			{ok,Req1,State#{?STATE_TOKEN := Token1}};
% 		<<"image">> ->
% 			{Token1,_ResData} = utake1_itake1:handle('IMAGE',Content2,Token0),
% 			% ?myPrint("image reply data",length(ResData)),

% 			[MediaId] 			= 		maps:get(<<"MediaId">>,Content2),
% 			[CreateTime] 		= 		maps:get(<<"CreateTime">>,Content2),
% 			[ToUserName]		=		maps:get(<<"ToUserName">>,Content2),
% 			[FromUserName]		=		maps:get(<<"FromUserName">>,Content2),

% 			Reply0 = [
% 				<<"<xml>">>,
% 				<<"<ToUserName><![CDATA[">>,ToUserName,<<"]]></ToUserName>">>,
% 				<<"<FromUserName><![CDATA[">>,FromUserName,<<"]]></FromUserName>">>,
% 				<<"<CreateTime>">>,CreateTime,<<"</CreateTime>">>,
% 				<<"<MsgType><![CDATA[">>,MsgType,<<"]]></MsgType>">>,
% 				<<"<Image>">>,
% 				<<"<MediaId><![CDATA[">>,MediaId,<<"]]></MediaId>">>,
% 				<<"</Image>">>,
% 				<<"</xml>">>
% 			],
% 			Reply1 = iolist_to_binary(Reply0),

% 			?myPrint("reply xml",Reply1),
% 			Req2 = cowboy_req:reply(
% 				200,
% 				#{<<"content-type">> => <<"application/xml">>},
% 				Reply1,
% 				% <<"">>,
% 				Req1
% 				),

% 			{ok,Req2,State#{?STATE_TOKEN := Token1}};
% 		_NotYetForOtherMsgType ->
% 			{ok,Req1,State}
% 	end;

% handle(_,Req,State) ->
% 	cowboy_req:reply(405,Req,State).



% for pass wechat token identification ==================
% handle(<<"GET">>,Req,State) ->
% 	Qs1 = cowboy_req:parse_qs(Req),
% 	{_,Echo} = lists:nth(2,Qs1),
% 	Req1 = cowboy_req:reply(
% 			200,
% 			#{<<"content-type">> => <<"text/plain">>},
% 			Echo,
% 			Req
% 			),
	% {ok,Req1,State}.
