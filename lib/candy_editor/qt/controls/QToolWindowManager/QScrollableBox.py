from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QScrollArea, QSizePolicy, QLayout


class QScrollableBox ( QWidget ):

	def __init__ ( self, parent ):
		super ( QScrollableBox, self ).__init__ ( parent )
		mainLayout = QVBoxLayout ()
		mainLayout.setContentsMargins ( 0, 0, 0, 0 )
		self.scrollArea = QScrollArea ( self )
		sizePolicy = QSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )
		sizePolicy.setHorizontalStretch ( 0 )
		sizePolicy.setVerticalStretch ( 0 )
		self.scrollArea.setSizePolicy ( sizePolicy )
		self.scrollArea.setHorizontalScrollBarPolicy ( Qt.ScrollBarAlwaysOff )
		self.scrollArea.setVerticalScrollBarPolicy ( Qt.ScrollBarAsNeeded )
		self.scrollArea.setWidgetResizable ( True )

		mainLayout.addWidget ( self.scrollArea )
		self.setLayout ( mainLayout )
		scrollContents = QWidget ()
		self.m_layout = QVBoxLayout ()
		self.m_layout.setContentsMargins ( 0, 0, 0, 0 )
		self.m_layout.setSizeConstraint ( QLayout.SetNoConstraint )
		scrollContents.setLayout ( self.m_layout )

		self.scrollArea.setWidget ( scrollContents )

	def addWidget ( self, w ):
		if not w:
			return
		count = self.m_layout.count ()
		if count > 1:
			self.m_layout.removeItem ( self.m_layout.itemAt ( count - 1 ) )
		self.m_layout.addWidget ( w )
		w.show ()
		self.m_layout.addStretch ()
		self.scrollArea.update ()

	def removeWidget ( self, w ):
		self.m_layout.removeWidget ( w )
		self.scrollArea.update ()

	def insertWidget ( self, i, w ):
		self.m_layout.insertWidget ( i, w )
		self.scrollArea.update ()

	def clearWidgets ( self ):
		item = self.m_layout.takeAt ( 0 )
		while item != None:
			item.widget ().deleteLater ()
			self.m_layout.removeItem ( item )
			del item

		self.scrollArea.update ()

	def indexOf ( self, w ):
		return self.m_layout.indexOf ( w )
