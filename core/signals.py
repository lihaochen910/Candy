from dispatch import Signal
from dispatch.idle_queue import idle_loop,idle_add
import logging

SIGNALS={}

def dispatchAll():
	if idle_loop.empty(): return False
	while not idle_loop.empty():
		c=idle_loop.get()
		c()
	return True

def dispatchPartial( count ):
	if idle_loop.empty(): return False
	while not idle_loop.empty():
		c=idle_loop.get()
		c()
		count -= 1
		if count <= 0: return True
	return True

def connect(name, handler):
	sig=SIGNALS.get(name,None)
	if sig is None: raise Exception('SIGNAL undefined: %s '%name)
	sig.connect(handler)

def disconnect(name,handler):
	sig=SIGNALS.get(name,None)
	if sig is None: raise Exception('SIGNAL undefined: %s '%name)
	sig.disconnect(handler)

def tryConnect(name, handler):
	sig=SIGNALS.get(name,None)
	if sig is None: return
	sig.connect(handler)

def emit(name, *args, **kwargs):
	sig=SIGNALS.get(name,None)
	if sig is None: raise Exception('SIGNAL undefined: %s '%name)
	sig.emit(*args,  **kwargs)

# def emitUpdate(name, *args, **kwargs):
# 	sig=SIGNALS.get(name,None)
# 	if sig is None: raise Exception('SIGNAL undefined: %s '%name)
# 	sig.emitUpdate(*args, **kwargs)

def emitNow(name,*args, **kwargs):
	sig=SIGNALS.get(name,None)
	if sig is None: raise Exception('SIGNAL undefined: %s '%name)
	sig.emitNow(*args,  **kwargs)

def register( name ):
	if not SIGNALS.get(name,None) is None :raise Exception('SIGNAL duplicated: %s '%name)
	logging.debug( 'register signal: %s ' % name )
	sig = Signal( name=name )
	# sig=Signal()
	# sig.description = description
	# sig.name=name
	SIGNALS[name]=sig
	return sig

def unregister(name):
	del SIGNALS[name]

def get(name):
	return SIGNALS.get(name,None)

def affirm(name):
	sig=SIGNALS.get(name,None)
	if sig is None: raise Exception('SIGNAL undefined: %s '%name)
	return sig

#call func at next dispatch
def callAfter(func, *args, **kwargs):
	idle_add(func, *args, **kwargs)


##Editor Global Signals
register('app.activate')
register('app.deactivate')

register('app.pre_start')
register('app.start')
register('app.ready')
register('app.close')
register('app.stop')
register('app.chdir')
register('app.command')
register('app.remote')

register('module.loaded')

register( 'command.new'  )
register( 'command.undo' )
register( 'command.redo' )
register( 'command.clear' )

register('game.pause')
register('game.resume')

register('preview.start')
register('preview.resume')
register('preview.stop')
register('preview.pause')

register('debug.enter')
register('debug.exit')
register('debug.continue')
register('debug.stop')

register('debug.command')
register('debug.info')

register('file.modified')
register('file.removed')
register('file.added')
register('file.moved')

register('module.register')
register('module.unregister')
register('module.load')
register('module.unload')

register('selection.changed')
register('selection.hint')

register('project.init')
register('project.preload')
register('project.presave')
register('project.load')
register('project.save')

register('project.pre_deploy')
register('project.deploy')
register('project.post_deploy')
register('project.done_deploy')

register('asset.reset')
register('asset.post_import_all')
register('asset.added')
register('asset.removed')
register('asset.modified')
register('asset.moved')
register('asset.deploy.changed')

register('asset.register')
register('asset.unregister')


if __name__ == '__main__':
	import dispatch
	print(dispatch)
