from AKU import getAKU

import qt
import moai
import sceneEditor
import assetEditor

from core.EditorModule import EditorModuleManager
from core.EditorApp import app

from packages.WelcomeScreen import *
from core import Project

# import logging
# logging.getLogger().setLevel(logging.INFO)

# WelcomeScreen.launch()

Project.get().load('../test')

app.run()
