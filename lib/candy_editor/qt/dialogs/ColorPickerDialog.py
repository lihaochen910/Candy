from candy_editor.core import *

from candy_editor.qt.controls.ColorPickerWidget import ColorPickerWidget
from candy_editor.qt.helpers import restrainWidgetToScreen

from PyQt5 import QtGui
from PyQt5.QtCore import Qt
from PyQt5.QtCore import QEvent, QObject, QPoint
from PyQt5.QtGui import QColor


##----------------------------------------------------------------##
class WindowAutoHideEventFilter ( QObject ):
	def eventFilter ( self, obj, event ):
		e = event.type ()
		if e == QEvent.KeyPress and event.key () == Qt.Key_Escape:
			obj.cancelled = True
			obj.hide ()
		elif e == QEvent.WindowDeactivate:
			obj.hide ()

		return QObject.eventFilter ( self, obj, event )


class ColorPickerDialog ( ColorPickerWidget ):
	def __init__ ( self, *args ):
		self.onCancel  = None
		self.onChange  = None
		self.onChanged = None
		self.cancelled = False

		super ( ColorPickerDialog, self ).__init__ ( *args )
		self.installEventFilter ( WindowAutoHideEventFilter ( self ) )
		self.setWindowTitle ( 'Colors' )
	
	def request ( self, **option ):
		self.onCancel  = None
		self.onChange  = None
		self.onChanged = None
		original = option.get ( 'original_color', None )
		if original:
			self.setColor ( QColor ( original ) )
			self.setOriginalColor ( original )

		self.onCancel  = option.get ( 'on_cancel',  None )
		self.onChange  = option.get ( 'on_change',  None )
		self.onChanged = option.get ( 'on_changed', None )

		pos = option.get ( 'pos', QtGui.QCursor.pos () )
		self.move ( pos + QPoint ( -50, 0 ) )
		restrainWidgetToScreen ( self )
		self.ui.buttonOK.setFocus ()
		self.show ()
		self.raise_ ()
		self.cancelled = False

	def onButtonOK ( self ):
		if self.onChanged:
			self.onChanged ( self.currentColor )
		self.hide ()

	def onButtonCancel ( self ):
		self.cancelled = True
		self.hide ()

	def onColorChange ( self, color ):
		if self.onChange:
			self.onChange ( color )

	def hideEvent ( self, ev ):
		if self.cancelled and self.onCancel:
			self.onCancel ()
		self.onCancel  = None
		self.onChange  = None
		self.onChanged = None


##----------------------------------------------------------------##
_colorPickerDialog = None
def requestColorDialog ( title = None, **option ):
	global _colorPickerDialog
	if not _colorPickerDialog:
		_colorPickerDialog = ColorPickerDialog ( None )
	if title:
		_colorPickerDialog.setWindowTitle ( title or 'Color Picker' )
	_colorPickerDialog.request ( **option )
	return _colorPickerDialog
