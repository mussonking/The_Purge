######################################################
### Set all default values at server start############
######################################################
set_timeout(1000, closure(
sudo('/scoreboard teams empty civils')
sudo('/scoreboard teams empty purgers')
_endresetarray()
 ))
		set_timeout(60000, closure(
		_startgame()
			))
 

######################################################
### If a player leave the game #######################
######################################################
bind(player_quit, null, null, @event,
	@verify = _verify()
	@quitname = @event['player']
	###If the player is NOT ingame or on waitlist
	if(!array_contains(@verify, @quitname)) {
		die()
		}
		@timeleft = _timeleft()
	if(@timeleft > 8) {
	acc_subtract(@quitname, 10)
	}
	###If the player is a purger
	@purgerlist = import('purger.game')
	if(array_contains(@purgerlist, @quitname)) {
		if(array_size(@purgerlist) == '1') {
			_endgame('civil')
			die()
			} 
				_remove_purger(@quitname)
				broadcast(color(a).'A Purger left the game. There is 'array_size(@purgerlist)' Purger(s) left.')
				die()
				
	}
	###If the player is a civil
	@civillist = import('civil.game')
	if(array_contains(@civillist, @quitname)) {
		if(array_size(@civillist) == '1') {
			_endgame('purger')
			die()
			}
				_remove_civil(@quitname)
				broadcast(color(b).'A civil left the game. There is 'array_size(@civillist)' Civil(s) left.')
				die()
				
		}
			###If the player is on waiting list
	@waitinglist = import('wait.list')
	if(array_contains(@waitinglist, @quitname)) {
		_remove_waiting(@quitname)
		die()
		}
			###If the player is on teamchoice.civils
	@tccivilslist = import('teamchoice.civils')
	if(array_contains(@tccivilslist, @quitname)) {
		_remove_tccivils(@quitname)
		die()
		}
			###If the player is on teamchoice.civils
	@tcpurgerslist = import('teamchoice.purgers')
	if(array_contains(@tcpurgerslist, @quitname)) {
		_remove_tcpurgers(@quitname)
		die()
		}
	)
#######################################################
### When any player join the server ###################
#######################################################

bind(player_join, null, null, @playerjoinevent,
@player = @playerjoinevent['player']
set_timeout(2000, closure(
set_ploc(@player, import('ident.purge.spawn'))
set_pmode(@player, 'ADVENTURE')
@timer = import('timer.waitinglist')
if(@timer == 'on') {
_addtolist(@player)
}
)))

#######################################################
### When any player Respawn (From dying) ##############
#######################################################

bind(player_spawn, null, null, @playerspawnevent,
@verify = _verify()
@respawnname = @playerspawnevent['player']
@timerwaitinglist = import('timer.waitinglist')
if(@timerwaitinglist != 'off') {
modify_event('location', import('ident.purge.spawn'))
} 
if(!array_contains(@verify, @respawnname)) {
modify_event('location', import('ident.purge.spawn'))
}
@civilarray = import('purger.game')
if(array_contains(@civilarray, @respawnname)) {
modify_event('location', import('ident.purge.purger'))
set_timeout(5000, closure(
			_emptyinv(@respawnname)
				pgive_item(@respawnname, 306, 1)
				pgive_item(@respawnname, 307, 1)
				pgive_item(@respawnname, 308, 1)				
				pgive_item(@respawnname, 309, 1)
				pgive_item(@respawnname, 267, 1)
				pgive_item(@respawnname, 391, 10)
))
}
)

#######################################################
###   Kill Bind, Action when anyone get killed   ######
#######################################################
bind(player_death, null, null, @killbind,
	@killedplayer = @killbind['player']
	@killer = @killbind['killer']
	@civillist = import('civil.game')
	###If the killed player is a civil
	if(array_contains(@civillist, @killedplayer)) {
		###If the civil killed was the last one alive.
		if(array_size(@civillist) == '1') { 
			_endgame('purger')
			die()
			}
			sudo('/scoreboard teams join purgers' @killedplayer)
		###Change the player to the right array (Civil --> Purger)
		@purgerlist = import('purger.game')
		array_remove_values(@civillist, @killedplayer)
		array_push(@purgerlist, @killedplayer)
		export('civil.game', @civillist)
		export('purger.game', @purgerlist)
		if(@kill != null) {
		tmsg(@killer, color(2).'You killed' @killedplayer 'You have been awarned 3$')
		acc_add(@killer, '3')
		}
		if(_timeleft() < 3) {
		acc_add(@killedplayer, '5')
		tmsg(@killedplayer, color(2).'You have been awarned 5$ for surviving more then 7 minutes')
		}
	##### BROADCAST PART ######
		###If this is not the last civil alive
		if(array_size(@civillist) > '1') {
			broadcast(color(b).'A civil just got killed. There is 'array_size(@civillist)' Civils left.')
			}
		###If this is the last civil alive
		if(array_size(@civillist) == '1') {
			broadcast(color(b).'A Civil just got killed. There is Only one Civil alive!!')
			}
		die()
	}
	###If the killed player was a Purger
	@purgerlist = import('purger.game')
	if(array_contains(@purgerlist, @killedplayer)) {
			###If the purger killed was the last one alive.
		if(array_size(@purgerlist) == '1') { 
			_endgame('civil')
			die()
			}
		sudo('/scoreboard teams leave' @killedplayer)
		###Change the player to the right array (Purger --> No array)
		array_remove_values(@purgerlist, @killedplayer)
		export('purger.game', @purgerlist)
		if(@kill != null) {
		tmsg(@killer, color(2).'You killed' @killedplayer 'You have been awarned 5$')
		acc_add(@killer, '5')
		}
		tmsg(@killedplayer, color(2).'You Have been killed. You lost 2$')
		acc_subtract(@killedplayer, '2')
	##### BROADCAST PART ######
		###If this is not the last civil alive
		if(array_size(@purgerlist) > '1') {
			broadcast(color(b).'A Purger just got killed. There is 'array_size(@purgerlist)' Purgers left.')
			}
		###If this is the last civil alive
		if(array_size(@purgerlist) == '1') {
			broadcast(color(b).'A Purger just got killed. There is Only one Purger alive!!')
			}
	} 
)

 
