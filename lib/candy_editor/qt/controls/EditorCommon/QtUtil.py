from PyQt5.QtGui import QCursor


def getMousePosition ( widget ):
	return widget.mapFromGlobal ( QCursor.pos () )

def getMouseScreenPosition ():
	return QCursor.pos ()

def isParentOf ( parent, child ):
	assert child

	o = child.parent ()
	while o:
		if o == parent:
			return True
		else:
			o = o.parent ()

	return False

def openInExplorer ( path ):
	pass

def pixelScale ( widget, qtValue ):
	return qtValue * widget.devicePixelRatioF ()

def qtScale ( widget, pixelValue ):
	return pixelValue / widget.devicePixelRatioF ()
