from AKU import getAKU

aku = getAKU()
aku.resetContext()
aku.setInputConfigurationName('CANDY')
aku.runString("print('Hi, Moai')")
