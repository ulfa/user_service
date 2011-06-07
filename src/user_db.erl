%% Copyright 2010 Ulf
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

%%% -------------------------------------------------------------------
%%% Author  : Ulf uaforum1@googlemail.com
%%% Description :
%%%
%%% Created : 
%%% -------------------------------------------------------------------
-module(user_db).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("../include/user_service.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([create_db/0, find_by_email_credential/2]).
%% --------------------------------------------------------------------
%% record definitions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
create_db() ->
		case mnesia:create_schema([node()]) of 
		{error, Reason} -> error_logger:info_msg(Reason),
						   false;
		_ -> application:start(mnesia),
			 mnesia:create_table(users, [{disc_copies, [node()]}, {attributes, record_info(fields, users)}]),
			 mnesia:wait_for_tables([users], 100000),
			 upload_users(),
			 %%application:stop(mnesia),
			 ok
	end.

upload_users() ->
	error_logger:info_msg("start : load the users~n"),
	mnesia:load_textfile("data/users.data"),
	error_logger:info_msg("end : load the users~n").

find_by_email_credential(Email, Credetial) ->
	mnesia:activity(transaction, fun() ->
		qlc:e(qlc:q([User || User <- mnesia:table(users), User#users.email =:= Email, User#users.password =:= Credetial])) 
	end).
%% --------------------------------------------------------------------
%%% Test functions
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.