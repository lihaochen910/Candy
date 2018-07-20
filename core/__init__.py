##----------------------------------------------------------------##
import core.signals

from project        import Project
from asset          import AssetLibrary, AssetException, AssetNode, AssetManager, AssetCreator
from cache          import CacheManager

##----------------------------------------------------------------##
from Command        import EditorCommand, EditorCommandStack, EditorCommandRegistry
from Command        import RemoteCommand, RemoteCommand, RemoteCommandRegistry
from EditorModule   import EditorModule
from EditorApp      import app

def getProjectPath( path = None ):
	return Project.get().getBasePath( path )

def getAppPath( path = None ):
	return app.getPath( path )