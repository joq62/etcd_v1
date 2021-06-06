-module(db_cluster_info).
-import(lists, [foreach/2]).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").

-define(TABLE,cluster_info).
-define(RECORD,cluster_info).
-record(cluster_info,{
		      cluster_name,
		      cookie
		  }).

% Start Special 

% End Special 
create_table()->
    mnesia:create_table(?TABLE, [{attributes, record_info(fields, ?RECORD)}]),
    mnesia:wait_for_tables([?TABLE], 20000).

create_table(NodeList)->
    mnesia:create_table(?TABLE, [{attributes, record_info(fields, ?RECORD)},
				 {disc_copies,NodeList}]),
    mnesia:wait_for_tables([?TABLE], 20000).

create(ClusterName,Cookie)->
    Record=#?RECORD{
		    cluster_name=ClusterName,
		    cookie=Cookie
		   },
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).

read_all() ->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    [{ClusterName,Cookie}||{?RECORD,ClusterName,Cookie}<-Z].

name()->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    R=[ClusterName||{?RECORD,ClusterName,_Cookie}<-Z],
    Name=case R of
	     []->
		 {error,[eexists]};
	     [ClusterName] ->
		 ClusterName
	 end,
    Name.
cookie()->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    R=[Cookie||{?RECORD,_ClusterName,Cookie}<-Z],
    ClusterCookie=case R of
		      []->
			  {error,[eexists]};
		      [Cookie] ->
			  Cookie
		  end,
    ClusterCookie.


do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.

%%-------------------------------------------------------------------------
