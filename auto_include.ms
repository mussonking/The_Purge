################################################
###   _combinelist()  Procedure
###   to combine the jail list arrays 
###   into one big array.
################################################
proc(_verify,
	@combine1 = import('purge.list')
	@combine2 = import('wait.list')

##the returned array##
	if(!is_array(@combine1)) {
	return(@combine2) 
	die()
	}
	if(!is_array(@combine2)) {
	return(@combine1)
	die()
	}
		@combinelist = array_merge(@combine1, @combine2)
			return(@combinelist)
)



################################################
###_emptyinv(player()) 
###   Procedure that emtpy inventory
###   and armor of designated player
################################################
proc(_emptyinv, @player,

	@empty = array(
				null, null, null, null, null, null, null, null, null, null, 
				null, null, null, null, null, null, null, null, null, null,
				null, null, null, null, null, null, null, null, null, null,
				null, null, null, null, null, 100:null, 101:null, 102:null, 103:null
			)

	if(@player == '',
		return(@empty),
		set_pinv(@player, @empty)
		return(true)
	)
	)
################################################
###_addtolist(player()) 
###   Procedure that add player to the
###   next game array
################################################
proc(_addtolist, @player,
	_emptyinv(@player)
	@waitarray = import('wait.list')
	@purgearray = import('purge.list')
	@corearray = import('core.reset')
	if(!array_contains(@corearray, @player)) {
	array_push(@corearray, @player)
	export('core.reset', @corearray)
	array_push(@waitarray, @player)
	export('wait.list', @waitarray)
	array_push(@purgearray, @player)
	export('purge.list', @purgearray)
	}
)
#####################################################
###_addtoviplist(player()) 
###   Procedure that add player to the
###   next game specified team array (donator only)
#####################################################
proc(_addtoviplist, @teamchoice, @player, 
	_emptyinv(@player)
	@teamarray = import('teamchoice.'.@teamchoice)
	@purgearray = import('purge.list')
	@corearray = import('core.reset')
	array_push(@corearray, @player)
	export('core.reset', @corearray)
	array_push(@teamarray, @player)
	export('teamchoice.'.@teamchoice, @teamarray)
	array_push(@purgearray, @player)
	export('purge.list', @purgearray)
)
################################################
###_startgame(gamenumber) 
###   Procedure that start a game from the
###   wait.list.#
################################################
proc(_startgame,
	broadcast(color(6).'Game Starting in 1 minutes, type 'color(4).'/purge join'.color(6).', if not already done, To join the next game!')
	set_timeout(30000, closure(
		_remindjoin()
		broadcast(color(6).'Game Starting in 30 seconds, type 'color(4).'/purge join'.color(6).', if not already done, To join the next game!')
		) )
	set_timeout(60000, closure(  #time for countdown(adjust second timeout too!)
		@waitarray = import('purge.list') ###import all player waiting to start next game.
		if(array_size(@waitarray) < 6) { #minimum number of players to start a game
		export('invite.cmd', 'off')
			broadcast(color(4).'Need minimum 6 players to Start the game. Currently have:'array_size(@waitarray))
			_startgame()
			if(array_size(@waitarray) > 1) {
			broadcast(color(2).'Invite people to join the game by typing'color(e)'/inviteall')
			}
			die()
			}
		@waitarray = import('wait.list')
		@divider = array_size(@waitarray) * 2 / 5   # /4 = 25% purgers, 75% civils
		###spliting the group in 2 arrays. Civil and purger
		@purgerarray = array_rand(@waitarray, integer(@divider), false)
		foreach(@purgerarray, @pname) {
		array_remove_values(@waitarray, @pname)
		}
		@civilarray = @waitarray
		@forcedcivils = import('teamchoice.civils')
		@forcedpurgers = import('teamchoice.purgers')
		if(array_size(@forcedcivils) > 0) {
			foreach(@forcedcivils, @cname) {
			array_push(@civilarray, @cname)
			}
		}
		if(array_size(@forcedpurgers) > 0) {
			foreach(@forcedpurgers, @puname) {
			array_push(@purgerarray, @puname)
			}
		}
			foreach(@civilarray, @name) {
					tmsg(@name, color(2).'You have been added to the Civils Team')
			}
			foreach(@purgerarray, @name) {
					tmsg(@name, color(2).'You have been added to the Purgers Team. You will be teleported in 1 minute.')
			}
		export('purger.game', @purgerarray)
		export('civil.game', @civilarray)
		export('wait.list', array())
		export('timer.waitinglist', 'off')	###Player cant join waiting list anymore.
		###Teleport civil in there spawn
		set_timeout(5000, closure(
			foreach(@civilarray, @name) {
				set_ploc(@name, import('ident.purge.civil'))
				sudo('/scoreboard teams join civils' @name)
				acc_add(@name, '100')

				}
								broadcast(color(2).'Civils were teleported to there spawn. They have 1 minutes to hide themself.')
			))
		###Teleport purger in there spawn
		set_timeout(60000, closure(
			foreach(@purgerarray, @name) {
				set_ploc(@name, import('ident.purge.purger'))
				sudo('/scoreboard teams join purgers' @name)
				acc_add(@name, '100')

				}
								broadcast(color(2).'Purgers have been teleported. They can now hunt Civils!')))
				###Starting the timeout to auto restart the game after 15 minutes
			    @endtimeout = set_timeout(540000, closure(
					broadcast(color(6).'One minute left before Civils survive The Purge')))
					@end3time = set_timeout(300000, closure(
					broadcast(color(6).'5 minutes left before the end of the game')))
					@end2time = set_timeout(600000, closure(
						_endgame('civil')
						))
				@starttime = add(time(),660000)
				export('starttime', @starttime)
				export('endtimeout', @endtimeout)
				export('end2time', @end2time)
				export('end3time', @end3time)
			))
		)
	
################################################
###_remindjoin()
###   Procedure that end a game 
###
################################################
proc(_remindjoin,
@purgelist = import('purge.list')
@allplayer = all_players()
foreach(@allplayer, @name) {
if(!array_contains(@purgelist, @name)) {
tmsg(@name, color(e).'You did'color(4).'NOT'color(e).'Join The Purge waiting list yet. Type:'color(4).'/purge join'color(e).'Fast to Join the next game!')
	}
	}
	)
################################################
###_endgame(@winnername) 
###   Procedure that end a game 
###
################################################
proc(_endgame, @winnername,
###If timer runs out --> Civils win the game
@end1 = import('end2time')
@end2 = import('endtimeout')
@end3 = import('end3time')
clear_task(@end1)
clear_task(@end2)
clear_task(@end3)
	if(equals(@winnername, 'civil')) {
		broadcast(color(d).'Time is 'color(4).'Over! 'color(c).'Civils 'color(d).'have 'color(4).'WON 'color(d).'the game! They survived 'color(4).'The Purge!!!')
		_teleportallspawn()
		_coreprotectmapreset()
		_nextgametimeout()
		_resetkits()
		_resetgroup()
		_endresetgamearray()
		die()
		}
###If all civils get killed --> purgers win the game
	if(equals(@winnername, 'purger')) {
		broadcast(color(d).'The last Civil was 'color(4).'killed! 'color(c).'Purgers 'color(d).'have 'color(4).'WON 'color(d).'the game! They killed all 'color(4).'Civils!!!')
		_teleportallspawn()
		_coreprotectmapreset()
		_nextgametimeout()
		_resetgroup()
		_resetkits()
    	_endresetgamearray()
		die()
		}
	)

################################################
###_nextgametimeout() 
###   Procedure that set_timout the start of 
###   the next game.
################################################
proc(_nextgametimeout,
		set_timeout(120000, closure(
			export('timer.waitinglist', 'on')
			broadcast(color(6).'Map reset is done. You can now type 'color(4).'/purge join' color(6).'To join the next game!')
			
			))
		set_timeout(150000, closure(
		_startgame()
			))
	)
################################################
###_coreprotectmapreset() 
###   Procedure that set group back to default 
###   of all name on purge.list
################################################
proc(_coreprotectmapreset,
broadcast(color(3).'Map is reseting. please wait 2 minutes for complete reset.')
export('invite.cmd', 'off')
broadcast(color(3).'You can now use /inviteall')
@corelist = import('core.reset')
@time = '1'
sudo('/co rollback t:15m #tnt r:#global')
set_timeout(20000, closure(
sudo('/co rollback t:15m #water r:#global')
))
set_timeout(24000, closure(
foreach(@corelist, @name) {
@time = add(@time, 2000)
set_timeout(@time, closure(
sudo('/co rollback t:15m u:'.@name' r:#global')
	}
	))))
	)
	
################################################
###_resetkits() 
###   Procedure that set_timout the start of 
###   the next game.
################################################
proc(_resetkits,
@pkits = import('kits.list') 	
foreach(@pkits, @name) {
export('kit.'.@name, 'off')
}
)
################################################
###_resetgroup() 
###   Procedure that set group back to default 
###   of all name on purge.list
################################################
proc(_resetgroup,
sudo('/scoreboard teams empty civils')
sudo('/scoreboard teams empty purgers')
	)
	
################################################
###_teleportallspawn() 
###   Procedure that Teleport all player in 
###   purge.list to spawn
################################################	
proc(_teleportallspawn,
@telearray = import('purge.list')
foreach(@telearray, @name) {
if(ponline(@name)) {
				set_ploc(@name, import('ident.purge.spawn'))
				_emptyinv(@name)
				acc_add(@name, '20')
				tmsg(@name, 'You have been awarned 20$ for finishing the game!')
				}
				}
	)
################################################
###_timeleft() 
###   Procedure that calculate time left to 
###   current game
################################################	
proc(_timeleft,
@starttime = import('starttime')
@timeleft = subtract(@starttime, time())
@timeleft = integer(@timeleft/1000/60)
return(@timeleft)
)

	
################################################
###_remove_purger(@removename) 
###   Procedure that remove a player from the
###   purger array & purge.list
################################################
proc(_remove_purger, @removename,
	### Remove the name from purge.list
	@purgelist = import('purge.list')
	array_remove_values(@purgelist, @removename)
	export('purge.list', @purgelist)
	### Remove the name from purger.game
	@purgerlist = import('purger.game')
	array_remove_values(@purgerlist, @removename)
	export('purger.game', @purgerlist)
	sudo('/scoreboard teams leave' @removename)
	)
	
################################################
###_remove_civil(@removename) 
###   Procedure that remove a player from the
###   civil array & purge.list
################################################
proc(_remove_civil, @removename,
	### Remove the name from purge.list
	@purgelist = import('purge.list')
	array_remove_values(@purgelist, @removename)
	export('purge.list', @purgelist)
	### Remove the name from civil.game
	@civillist = import('civil.game')
	array_remove_values(@civillist, @removename)
	export('civil.game', @civillist)
	sudo('/scoreboard teams leave' @removename)
	)
################################################
###_remove_waiting(@removename) 
###   Procedure that remove a player from the
###   waiting array & purge.list
################################################
proc(_remove_waiting, @removename,
	### Remove the name from purge.list
	@purgelist = import('purge.list')
	array_remove_values(@purgelist, @removename)
	export('purge.list', @purgelist)
	### Remove the name from wait.list
	@waitinglist = import('wait.list')
	array_remove_values(@waitinglist, @removename)
	export('wait.list', @waitinglist)
	)
################################################
###_remove_tcpurgers(@removename) 
###   Procedure that remove a player from the
###   teamchoice array & purge.list
################################################
proc(_remove_tcpurgers, @removename,
	### Remove the name from purge.list
	@purgelist = import('purge.list')
	array_remove_values(@purgelist, @removename)
	export('purge.list', @purgelist)
	### Remove the name from wait.list
	@tclist = import('teamchoice.purgers')
	array_remove_values(@tclist, @removename)
	export('teamchoice.purgers', @tclist)
	)
################################################
###_remove_tccivils(@removename) 
###   Procedure that remove a player from the
###   teamchoice array & purge.list
################################################
proc(_remove_tccivils, @removename,
	### Remove the name from purge.list
	@purgelist = import('purge.list')
	array_remove_values(@purgelist, @removename)
	export('purge.list', @purgelist)
	### Remove the name from wait.list
	@tclist = import('teamchoice.civils')
	array_remove_values(@tclist, @removename)
	export('teamchoice.civils', @tclist)
	)