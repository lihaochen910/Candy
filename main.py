from AKU import getAKU

from core.EditorModule import EditorModuleManager
from core.EditorApp import app

from packages.WelcomeScreen import *

def main():
	WelcomeScreen.launch()

	aku = getAKU()
	aku.resetContext()
	aku.setInputConfigurationName('CANDY')
	aku.runString("print('Hi, Moai')")

	app.run()

main()
