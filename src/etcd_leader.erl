%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(etcd_leader).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%%---------------------------------------------------------------------
%% Records & defintions
%%---------------------------------------------------------------------
-define(ControllerLeaderTime,30).

%%---- HostFile Info 
-define(GitHostConfigCmd,"git clone https://github.com/joq62/host_config.git").
-define(HostFile,"host_config/hosts.config").
-define(HostConfigDir,"host_config").



%% --------------------------------------------------------------------
-export([start/0]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start(),

    %% Create tables 
    ok=db_lock:create_table(),
    {atomic,ok}=db_lock:create(controller_leader,?ControllerLeaderTime),

    %---
    ok=db_host_info:create_table(),
    ok=load_config(?HostConfigDir,?HostFile,?GitHostConfigCmd),
    {ok,HostInfoConfig}=read_config(?HostFile),
    [db_host_info:create(HostId,Ip,SshPort,UId,Pwd)||
	    [{host_id,HostId},
	     {ip,Ip},
	     {ssh_port,SshPort},
	     {uid,UId},
	     {pwd,Pwd}]<-HostInfoConfig],
    %--
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
load_config(Dir,HostFile,GitCmd)->
    os:cmd("rm -rf "++Dir),
    os:cmd(GitCmd),
    Reply=case filelib:is_file(HostFile) of
	      true->
		  ok;
	      false->
		  {error,[noexist,HostFile]}
	  end,
    Reply.
%% --------------------------------------------------------------------
%% Function:start
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
read_config(HostFile)->
    Reply=case filelib:is_file(HostFile) of
	      true->
		  file:consult(HostFile);
	      false->
		  {error,[noexist,HostFile]}
	  end,
    Reply.
