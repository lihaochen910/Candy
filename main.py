from AKU import getAKU

import qt
import moai
import sceneEditor
import assetEditor

from core.EditorModule import EditorModuleManager
from core.EditorApp import app

from packages.WelcomeScreen import *

# import logging
# logging.getLogger().setLevel(logging.INFO)

# WelcomeScreen.launch()

app.openProject('./testProject')

app.run()
