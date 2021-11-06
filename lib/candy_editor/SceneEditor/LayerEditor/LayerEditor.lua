require 'candy'

function addLayer ()
	local l = candy.game:addLayer  ( 'layer' )
	return l
end

function setLayerName ( l, name )
	l:setName ( name )
end

function updatePriority ()
	for i, l in ipairs ( candy.game.layers ) do
		if l.name ~='CANDY_EDITOR_LAYER' then
			l.priority = i
		end
	end
	emitSignal ( 'layer.update', 'all', 'priority' )
	candy_editor.emitPythonSignal ( 'scene.update' )
end

function moveLayerUp ( l )
	local layers = candy.game.layers
	local i = table.index ( layers, l )
	assert  ( i )
	if i >= #layers then return end
	if layers[ i + 1 ].name =='CANDY_EDITOR_LAYER' then return end
	table.remove ( layers, i )
	table.insert ( layers, i + 1 , l )
	updatePriority ()
end

function moveLayerDown ( l )
	local layers = candy.game.layers
	local i = table.index ( layers, l )
	assert  ( i )
	if i <= 1 then return end
	if layers[ i - 1 ].name =='CANDY_EDITOR_LAYER' then return end
	table.remove ( layers, i )
	table.insert ( layers, i - 1 , l )
	updatePriority ()
end

function removeLayer ( layer )
	candy.game:removeLayer ( layer )
end
