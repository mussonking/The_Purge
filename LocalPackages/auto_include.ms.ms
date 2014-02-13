################################################
###_endresetarraytimer() 
###   Procedure that reset all arrays containing 
###   players and set timer to restart status
################################################
proc(_endresetarray,
	export('purge.list', array())
	export('wait.list', array())
	export('kits.list', array())
	export('purger.game', array())
	export('civil.game', array())
	export('core.reset', array())
	export('teamchoice.purgers', array())
	export('teamchoice.civils', array())
	export('timer.waitinglist', 'on')
	export('ident.purge.spawn', array('47', '39', '-264')) 
	export('ident.purge.civil', array('72', '14', '-141'))
	export('ident.purge.purger', array('-50', '29', '-397'))
)
proc(_endresetgamearray,
	export('purge.list', array())
	export('wait.list', array())
	export('purger.game', array())
	export('core.reset', array())
    export('kits.list', array())
	export('civil.game', array())
	export('teamchoice.purgers', array())
	export('teamchoice.civils', array())
	export('timer.waitinglist', 'reset')
	export('ident.purge.spawn', array('47', '39', '-264')) 
	export('ident.purge.civil', array('72', '14', '-141'))
	export('ident.purge.purger', array('-50', '29', '-397'))
)