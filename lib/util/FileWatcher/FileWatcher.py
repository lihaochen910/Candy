import os
import logging

from watchdog.observers import Observer
from watchdog.events    import PatternMatchingEventHandler
from candy_editor.core import EditorModule, app
from candy_editor.core import signals


##----------------------------------------------------------------##
class ModuleFileWatcher ( EditorModule ):
	def __init__ ( self ):
		super ( ModuleFileWatcher, self ).__init__ ()
		self.watches = {}

	def getName ( self ):
		return 'filewatcher'

	def getDependency ( self ):
		return []

	def onLoad ( self ):		
		self.observer = Observer ()
		self.observer.start ()
		
		signals.connect ( 'file.moved', self.onFileMoved )
		signals.connect ( 'file.added', self.onFileCreated )
		signals.connect ( 'file.removed', self.onFileDeleted )
		signals.connect ( 'file.modified', self.onFileModified )
		
	def onStart ( self ):
		self.assetWatcher = self.startWatch (
			self.getProject ().getAssetPath (),
			ignorePatterns = [ '*/.git', '**/.*', '*/_candy', '**/.*/', '*/.assetmeta/' ]
		)
		
	def startWatch ( self, path, **options ):
		path = os.path.realpath (path)
		if self.watches.get (path):
			logging.warning ( 'already watching: %s' % path )
			return self.watches[path]
		logging.info  ( 'start watching: %s' % path )
		
		ignorePatterns = [ '*/.git', '**/.*', '*/_candy' ] + options.get ( 'ignorePatterns', [] )

		handler = FileWatcherEventHandler (
			options.get ( 'patterns', None ),
			ignorePatterns,
			options.get ( 'ignoreDirectories', None ),
			options.get ( 'caseSensitive', True )
		)

		watch = self.observer.schedule ( handler, path, options.get ( 'recursive', True ) )
		self.watches[ path ] = watch
		return watch

	def onStop ( self ):
		# print 'stop file watcher'
		self.observer.stop ()
		self.observer.join ( 0.5 )
		# print 'stopped file watcher'

	def stopWatch ( self, path ):
		path  = os.path.realpath ( path )
		watch = self.watches.get ( path, None )
		if not watch: return
		self.observer.unschedule ( watch )
		self.watches[ path ] = None

	def stopAllWatches ( self ):
		# logging.info ('stop all file watchers')
		self.observer.unschedule_all ()
		self.watches = {}

	def onFileMoved ( self, path, newpath ):
		# print ('asset moved:',path, newpath)
		app.getAssetLibrary ().scheduleScanProject ()
		pass

	def onFileCreated ( self, path ):
		# print ('asset created:',path)
		app.getAssetLibrary ().scheduleScanProject ()
		pass

	def onFileModified ( self, path ):
		print ('asset modified:',path)
		app.getAssetLibrary ().scheduleScanProject ()
		pass

	def onFileDeleted ( self, path ):
		# print ('asset deleted:',path)
		app.getAssetLibrary ().scheduleScanProject ()
		pass

##----------------------------------------------------------------##
class FileWatcherEventHandler ( PatternMatchingEventHandler ):

	def on_moved ( self, event ):
		super ( FileWatcherEventHandler, self ).on_moved ( event )
		signals.emit ( 'file.moved', event.src_path, event.dest_path )

		# what = 'directory' if event.is_directory else 'file'
		# logging.info ("Moved %s: from %s to %s", what, event.src_path,
		# 						 event.dest_path)

	def on_created ( self, event ):
		super ( FileWatcherEventHandler, self ).on_created ( event )
		signals.emit ( 'file.added', event.src_path )

		# what = 'directory' if event.is_directory else 'file'
		# logging.info ("Created %s: %s", what, event.src_path)

	def on_deleted ( self, event ):
		super ( FileWatcherEventHandler, self ).on_deleted ( event )
		signals.emit ( 'file.removed', event.src_path )

		# what = 'directory' if event.is_directory else 'file'
		# logging.info ("Deleted %s: %s", what, event.src_path)

	def on_modified ( self, event ):
		super ( FileWatcherEventHandler, self ).on_modified ( event )
		signals.emit ( 'file.modified', event.src_path )

		# what = 'directory' if event.is_directory else 'file'
		# logging.info ("Modified %s: %s", what, event.src_path)


ModuleFileWatcher ().register ()