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

from helpers import *
from model import *

CANDY_MIME_ENTITY_DATA = 'application/candy.entity-data'
CANDY_MIME_ASSET_LIST  = 'application/candy.asset-list'

def getProjectPath( path = None ):
	return Project.get().getBasePath( path )

def getAppPath( path = None ):
	return app.getPath( path )