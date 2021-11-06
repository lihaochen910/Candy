import click
from candy_editor.core import app


@click.command ( help = 'start candy IDE' )
@click.option ( '--stop-other-instance',
                flag_value = True,
                default = False,
                help = 'whether stop other running instance' )
def run ( stop_other_instance ):
	app.openProject ( './ZGameProject' )
	# import candy_editor.moai
	from candy_editor import SceneEditor
	from candy_editor import AssetEditor
	# import candy_editor.DeviceManager
	# import candy_editor.DebugView
	# import candy_editor.ScriptView

	options = {}
	options[ 'stop_other_instance' ] = stop_other_instance

	# print ( 'starting candy IDE...' )

	app.run ( **options )


def main ( argv ):
	return run ( argv[ 1: ], 'candy ide' )
