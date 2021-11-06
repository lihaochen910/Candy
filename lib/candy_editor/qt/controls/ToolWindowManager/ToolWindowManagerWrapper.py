from PyQt5 import QtWidgets
from PyQt5.QtCore import qWarning, Qt
from PyQt5.QtWidgets import QWidget, QSplitter

from candy_editor.qt.controls.ToolWindowManager.ToolWindowManagerArea import ToolWindowManagerArea

class ToolWindowManagerWrapper ( QWidget ):

	def __init__ ( self, manager ):
		super ( ToolWindowManagerWrapper, self ).__init__ ( manager )
		self.manager = manager
		self.setWindowFlags ( self.windowFlags () | Qt.Tool )
		self.setWindowTitle ( '' )

		mainLayout = QtWidgets.QVBoxLayout ( self )
		mainLayout.setContentsMargins ( 0, 0, 0, 0 )
		self.manager.wrappers.append ( self )

	def closeEvent ( self, event ):
		'''
		关闭时处理所有拥有的ToolWindowManagerArea
		'''
		from .ToolWindowManager import ToolWindowManager
		toolWindows = []
		for widget in self.findChildren ( ToolWindowManagerArea ):
			toolWindows += widget.toolWindows ()
		self.manager.moveToolWindows ( toolWindows, ToolWindowManager.NoArea )

	def saveState ( self ):
		result = {}
		if self.layout ().count () > 1:
			qWarning ('too many children for wrapper')
			return result

		if self.isWindow () and self.layout ().count () == 0:
			qWarning ('empty top level wrapper')
			return result

		# result[ 'geometry' ] = str ( self.saveGeometry () )
		splitter = self.findChild ( QSplitter )
		if splitter:
			result[ 'splitter' ] = self.manager.saveSplitterState ( splitter )
		else:
			area = self.findChild ( ToolWindowManagerArea )
			if area:
				result[ 'area' ] = area.saveState ()
			elif self.layout ().count () > 0:
				qWarning ('unknown child')
				return {}
		return result

	def restoreState ( self, data ):
		if 'geometry' in data:
			self.restoreGeometry ( data['geometry'] )
		if self.layout ().count () > 0:
			qWarning ('wrapper is not empty')
			return
		if 'splitter' in data:
			self.layout ().addWidget (
				self.manager.restoreSplitterState ( data[ 'splitter' ].toMap () )
			)
		elif 'area' in data:
			area = self.manager.createArea ()
			area.restoreState ( data[ 'area' ] )
			self.layout ().addWidget ( area )

	def isOccupied ( self ):
		return self.layout ().count () > 0
