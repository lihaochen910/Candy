import logging

# loggingLevel = logging.WARNING
# loggingLevel = logging.INFO
# loggingLevel = logging.DEBUG


##----------------------------------------------------------------##
from . import signals

##----------------------------------------------------------------##
from .helpers import *
from .model import *
from .res import ResGuard
from .tool import ToolBase, startupTool
from .project import Project
from .asset import AssetLibrary, AssetException, AssetNode, AssetManager, AssetCreator
from .cache import CacheManager

##----------------------------------------------------------------##
from .Command import EditorCommand, EditorCommandStack, EditorCommandRegistry, RemoteCommand, RemoteCommandRegistry
from .EditorModule import EditorModule
from .EditorApp import app

##----------------------------------------------------------------##
# import .CoreModule


CANDY_MIME_ENTITY_DATA = 'application/candy.entity-data'
CANDY_MIME_ASSET_LIST = 'application/candy.asset-list'


def getProjectPath ( path = None ):
	return Project.get ().getBasePath ( path )


def getAppPath ( path = None ):
	return app.getPath ( path )
