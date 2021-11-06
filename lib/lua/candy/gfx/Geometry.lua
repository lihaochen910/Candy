--------------------------------------------------------------------
--@classmod Geometry
-- import
local ComponentModule = require 'candy.Component'
local DrawScript = require 'candy.gfx.DrawScript'

-- module
local GeometryModule = {}

local draw = MOAIDraw

--------------------------------------------------------------------
-- GeometryComponent
--------------------------------------------------------------------
---@class GeometryComponent : DrawScript
local GeometryComponent = CLASS: GeometryComponent ( DrawScript )
	:MODEL{
		Field 'index' :no_edit();		
		Field 'penWidth' :getset("PenWidth");
	}

function GeometryComponent:__init ()
	self.penWidth = 1
end

function GeometryComponent:getPenWidth ()
	return self.penWidth
end

function GeometryComponent:setPenWidth ( w )
	self.penWidth = w
end


--------------------------------------------------------------------
-- GeometryDrawScriptComponent
--------------------------------------------------------------------
---@class GeometryDrawScriptComponent : GeometryComponent
local GeometryDrawScriptComponent = CLASS: GeometryDrawScriptComponent ( GeometryComponent )
	:MODEL {}

function GeometryDrawScriptComponent:__init ()
	local prop = self.prop
	local deck = MOAIDrawDeck.new ()
	prop:setDeck ( deck )
	self.deck = deck
end

function GeometryDrawScriptComponent:onDraw ()
end

function GeometryDrawScriptComponent:onGetRect ()
	return 0, 0, 0, 0
end

function GeometryDrawScriptComponent:onAttach ( entity )
	GeometryDrawScriptComponent.__super.onAttach ( self, entity )
	self.deck:setDrawCallback ( function ( ... )
		return self:onDraw ( ... )
	end )
	self.deck:setBoundsCallback ( function ( ... )
		return self:onGetRect ( ... )
	end )
end


--------------------------------------------------------------------
-- GeometryRect
--------------------------------------------------------------------
---@class GeometryRect : GeometryComponent
local GeometryRect = CLASS: GeometryRect ( GeometryComponent )
	:MODEL{
		Field 'w' :on_set("updateDeck");
		Field 'h' :on_set("updateDeck");
		Field 'fill'  :boolean() :on_set("updateDeck");
	}
	
ComponentModule.registerComponent ( 'GeometryRect', GeometryRect )

function GeometryRect:__init ()
	self.w = 100
	self.h = 100
	self.fill = false
end

function GeometryRect:getSize ()
	return self.w, self.h
end

function GeometryRect:setSize ( w, h )
	self.w = w
	self.h = h
end

function GeometryRect:onDraw ()
	local w,h = self.w, self.h
	if self.fill then
		draw.fillRect( -w/2,-h/2, w/2,h/2 )
	else
		draw.setPenWidth( self.penWidth )
		draw.drawRect( -w/2,-h/2, w/2,h/2 )
	end
end

function GeometryRect:onGetRect ()
	local w,h = self.w, self.h
	return -w/2,-h/2, w/2,h/2
end

function GeometryRect:setFilled ( fill )
	self.fill = fill
end

function GeometryRect:isFilled ()
	return self.fill
end


--------------------------------------------------------------------
-- GeometryCircle
--------------------------------------------------------------------
---@class GeometryCircle : GeometryComponent
local GeometryCircle = CLASS: GeometryCircle ( GeometryComponent )
	:MODEL{
		Field 'radius' :on_set("updateDeck");
		Field 'fill' :boolean() :on_set("updateDeck");
	}

ComponentModule.registerComponent ( 'GeometryCircle', GeometryCircle )

function GeometryCircle:__init ()
	self.radius = 100
	self.fill = false
end

function GeometryCircle:getRadius ()
	return self.radius
end

function GeometryCircle:setRadius ( r )
	self.radius = r
end

function GeometryCircle:onDraw ()
	if self.fill then
		draw.fillCircle ( 0,0, self.radius )
	else
		draw.setPenWidth ( self.penWidth )
		draw.drawCircle ( 0,0, self.radius )
	end
end

function GeometryCircle:onGetRect ()
	local r = self.radius
	return -r,-r, r,r
end

--------------------------------------------------------------------
-- GeometryRay
--------------------------------------------------------------------
---@class GeometryRay : GeometryComponent
local GeometryRay = CLASS: GeometryRay ( GeometryComponent )
	:MODEL{
		'----';
		Field 'length' :set( 'setLength' );		
	}

ComponentModule.registerComponent( 'GeometryRay', GeometryRay )

function GeometryRay:__init()
	self.length = 100
end

function GeometryRay:onDraw()
	draw.setPenWidth( self.penWidth )
	local l = self.length
	draw.fillRect( -1,-1, 1,1 )
	draw.drawLine( 0, 0, l, 0 )
	draw.fillRect( -1 + l, -1, 1 + l,1 )
end

function GeometryRay:onGetRect()
	local l = self.length
	return 0,0, l,1
end

function GeometryRay:setLength( l )
	self.length = l
end


--------------------------------------------------------------------
-- GeometryBoxOutline
--------------------------------------------------------------------
---@class GeometryBoxOutline : GeometryComponent
local GeometryBoxOutline = CLASS: GeometryBoxOutline ( GeometryComponent )
	:MODEL{
		Field 'size' :type( 'vec3' ) :getset( 'Size' );
	}

ComponentModule.registerComponent ( 'GeometryBoxOutline', GeometryBoxOutline )

function GeometryBoxOutline:__init ()
	self.sizeX = 100
	self.sizeY = 100
	self.sizeZ = 100
end

function GeometryBoxOutline:getSize ()
	return self.sizeX, self.sizeY, self.sizeZ
end

function GeometryBoxOutline:setSize ( x,y,z )
	self.sizeX, self.sizeY, self.sizeZ = x,y,z
end

function GeometryBoxOutline:onDraw ()
	local x,y,z = self.sizeX/2, self.sizeY/2, self.sizeZ/2
	draw.setPenWidth ( self.penWidth )
	draw.drawBoxOutline ( -x, -y, -z, x, y, z )
end

function GeometryBoxOutline:onGetRect()
	local x,y,z = self.sizeX/2, self.sizeY/2, self.sizeZ/2
	return -x, -y, x, y
end


--------------------------------------------------------------------
-- GeometryLineStrip
--------------------------------------------------------------------
---@class GeometryLineStrip : GeometryComponent
local GeometryLineStrip = CLASS: GeometryLineStrip ( GeometryComponent )
	:MODEL{
		Field 'verts' :array( 'number' ) :getset( 'Verts' ) :no_edit();
		Field 'looped' :boolean() :isset( 'Looped' );
	}

ComponentModule.registerComponent ( 'GeometryLineStrip', GeometryLineStrip )

function GeometryLineStrip:__init ()
	self.looped = false
	self.boundRect = {0,0,0,0}
	self.outputVerts = {}
	self:setVerts{
		0,0,
		0,100,
		100,100,
		100, 0
	}
end

function GeometryLineStrip:setLooped ( looped )
	self.looped = looped
	self:updateVerts ()
end

function GeometryLineStrip:isLooped ()
	return self.looped
end

function GeometryLineStrip:onAttach ( ent )
	GeometryLineStrip.__super.onAttach ( self, ent )
	self:updateVerts ()
end

function GeometryLineStrip:getVerts ()
	return self.verts
end

function GeometryLineStrip:setVerts ( verts )
	self.verts = verts 
	self:updateVerts ()
end

function GeometryLineStrip:updateVerts ()
	if not self._entity then return end
	local verts = self.verts
	local x0,y0,x1,y1
	for i = 1, #verts, 2 do
		local x, y = verts[ i ], verts[ i + 1 ]
		x0 = x0 and ( x < x0 and x or x0 ) or x
		y0 = y0 and ( y < y0 and y or y0 ) or y
		x1 = x1 and ( x > x1 and x or x1 ) or x
		y1 = y1 and ( y > y1 and y or y1 ) or y
	end
	self.boundRect = { x0 or 0, y0 or 0, x1 or 0, y1 or 0 }
	local outputVerts = { unpack (verts) }
	if self:isLooped () then
		table.insert ( outputVerts, outputVerts[ 1 ] )
		table.insert ( outputVerts, outputVerts[ 2 ] )
	end
	self.outputVerts = outputVerts
end

function GeometryLineStrip:onDraw ()
	draw.setPenWidth ( self.penWidth )
	draw.drawLine ( unpack ( self.outputVerts ) )
end

function GeometryLineStrip:onGetRect ()
	return unpack ( self.boundRect )
end


--------------------------------------------------------------------
-- GeometryPolygon
--------------------------------------------------------------------
---@class GeometryPolygon : GeometryLineStrip
local GeometryPolygon = CLASS: GeometryPolygon ( GeometryLineStrip )
	:MODEL{
		Field 'looped' :boolean() :no_edit();
		Field 'fill' :boolean() :isset( 'Filled' );
	}

ComponentModule.registerComponent ( 'GeometryPolygon', GeometryPolygon )

local vtxFormat = MOAIVertexFormatMgr.getFormat ( MOAIVertexFormatMgr.XYZC )
function GeometryPolygon:__init ()
	self.looped = true
	self.fill = true
	local mesh = MOAIMesh.new ()
	mesh:setPrimType ( MOAIMesh.GL_TRIANGLES )
	mesh:setShader ( MOAIShaderMgr.getShader ( MOAIShaderMgr.LINE_SHADER_3D ))
	mesh:setTexture ( getWhiteTexture () )
	self.meshDeck = mesh
end

function GeometryPolygon:isFilled ()
	return self.fill
end

function GeometryPolygon:setFilled ( fill )
	self.fill = fill and true or false
	self:updatePolygon ()
end

function GeometryPolygon:isLooped ()
	return true
end

function GeometryPolygon:updateVerts ()
	GeometryPolygon.__super.updateVerts ( self )
	return self:updatePolygon ()
end

function GeometryPolygon:updatePolygon ()
	if not self.fill then
		self.prop:setDeck ( self.deck ) --use drawScriptDeck
		return
	else
		self.prop:setDeck ( self.meshDeck )
	end

	local verts = self.verts
	local count = #verts	
	if count < 6 then return end
	
	local tess = MOAIVectorTesselator.new ()
	tess:setFillStyle ( MOAIVectorTesselator.FILL_SOLID )
	tess:setFillColor ( 1,1,1,1 )
	tess:setStrokeStyle ( MOAIVectorTesselator.STROKE_NONE )
		tess:pushPoly()
			for k = 1, count/2 do
				local idx = (k-1) * 2
				tess:pushVertex ( verts[idx+1], verts[idx+2] )
			end
		tess:finish ()
	tess:finish ()

	local vtxBuffer = MOAIGfxBuffer.new ()
	local idxBuffer = MOAIGfxBuffer.new ()
	local totalElements = tess:getTriangles ( vtxBuffer, idxBuffer, 2 );

	local mesh = self.meshDeck
	mesh:setVertexBuffer ( vtxBuffer, vtxFormat )
	mesh:setIndexBuffer ( idxBuffer )
	mesh:setTotalElements ( totalElements )
	mesh:setBounds ( vtxBuffer:computeBounds ( vtxFormat ))

	--triangulate
	local x0,y0,x1,y1 = calcAABB ( self.verts )
	self.aabb  = { x0, y0, x1, y1 }

end


GeometryModule.GeometryComponent = GeometryComponent
GeometryModule.GeometryRect = GeometryRect
GeometryModule.GeometryCircle = GeometryCircle
GeometryModule.GeometryRay = GeometryRay
GeometryModule.GeometryBoxOutline = GeometryBoxOutline
GeometryModule.GeometryLineStrip = GeometryLineStrip
GeometryModule.GeometryPolygon = GeometryPolygon

return GeometryModule