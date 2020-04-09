import logging
import json

def saveJSON( data, path, **option ):
	outputString = json.dumps( data , 
			indent    = option.get( 'indent' ,2 ),
			sort_keys = option.get( 'sort_keys', True ),
			ensure_ascii=False
		).encode('utf-8')
	fp = open( path, 'wb+' )
	fp.write( outputString )
	fp.close()
	return True

def loadJSON( path ):
	fp = open ( path, encoding="utf-8" )
	# data = json.load( fp, 'utf-8' )
	data = json.load( fp )
	fp.close()
	return data


def trySaveJSON( data, path, dataName = None, **option ):
	try:
		saveJSON( data, path, **option )
		return True
	except Exception as e:
		logging.warn( 'failed to save %s: %s' % ( dataName or 'JSON', path ) )
		logging.exception( e )
		return False

def tryLoadJSON( path, dataName = None ):
	try:
		data = loadJSON( path )
		return data
	except Exception as e:
		logging.warn( 'failed to load %s: %s' % ( dataName or 'JSON', path ) )
		logging.exception( e )
		return False


def encodeJSON( inputData, **option ):
	outputString = json.dumps( inputData , 
			indent    = option.get( 'indent' ,2 ),
			sort_keys = option.get( 'sort_keys', True ),
			ensure_ascii=False
		).encode('utf-8')
	return outputString

def decodeJSON( inputString, **option ):
	data = json.loads( inputString , 'utf-8' )
	return data
