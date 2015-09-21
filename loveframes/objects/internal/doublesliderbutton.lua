--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

-- get the current require path
local path = string.sub(..., 1, string.len(...) - string.len(".objects.internal.doublesliderbutton"))
local loveframes = require(path .. ".libraries.common")

-- sliderbutton class
local newobject = loveframes.NewObject("doublesliderbutton", "loveframes_object_doublesliderbutton", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent, buttontype)

	self.type = "doublesliderbutton"
	self.width = 10
	self.height = 20
	self.staticx = 0
	self.staticy = 0
	self.startx = 0
	self.clickx = 0
	self.starty = 0
	self.clicky = 0
	self.intervals = true
	self.internal = true
	self.down = false
	self.dragging = false
	self.parent = parent
	self.buttontype = buttontype
	
	-- apply template properties to the object
	loveframes.templates.ApplyToObject(self)
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	self:CheckHover()
	
	local x, y = love.mouse.getPosition()
	local intervals = self.intervals
	local progress = 0
	
	local nvalue = 0
	local pMinValue = self.parent.minValue
	local pMaxValue = self.parent.maxValue
	
	local hover = self.hover
	local down = self.down
	local downobject = loveframes.downobject
	local parent = self.parent
	local slidetype = parent.slidetype
	local dragging = self.dragging
	local base = loveframes.base
	local update = self.Update
	
	if not hover then
		self.down = false
		if downobject == self then
			self.hover = true
		end
	else
		if downobject == self then
			self.down = true
		end
	end
	
	if not down and downobject == self then
		self.hover = true
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
	
	-- start calculations if the button is being dragged
	if dragging then
		-- calculations for horizontal sliders
		if slidetype == "horizontal" then
			
			-- опрометчиво сразу тут менять положение
			self.staticx = self.startx + (x - self.clickx)
			
			if self.buttontype == 'min' then
				progress = self.staticx / (self.parent.width - 2 * self.width) -- бегунка -то уже 2!!!
			elseif self.buttontype == 'max' then
				progress = (self.staticx - self.width) / (self.parent.width - 2 * self.width) -- бегунка -то уже 2!!!
			end
			
			nvalue = self.parent.min + (self.parent.max - self.parent.min) * progress
			nvalue = loveframes.util.Round(nvalue, self.parent.decimals)
--[[			
		-- calculations for vertical sliders
		elseif slidetype == "vertical" then
			self.staticy = self.starty + (y - self.clicky)
			local space = self.parent.height - self.height
			local remaining = (self.parent.height - self.height) - self.staticy
			local percent =  remaining/space
			nvalue = self.parent.min + (self.parent.max - self.parent.min) * percent
			nvalue = loveframes.util.Round(nvalue, self.parent.decimals)
]]
		end
		
		-- бред какой-то, чесслово...
		if nvalue == -0 then
			nvalue = math.abs(nvalue)
		end
		
		if self.buttontype == 'min' then
			
			if nvalue > self.parent.maxValue then
				nvalue = self.parent.maxValue -- может минус самое маленькое допустимое число ?!!!
			end
			
			if nvalue < self.parent.min then
				nvalue = self.parent.min
			end
			
			self.parent.minValue = nvalue
			
			
			-- корректируем координату бегунка
			-- self.staticx должен принять значение в соответствие с navalue
			
			self.staticx = (self.parent.width - 2 * self.width) * (nvalue - self.parent.min) / (self.parent.max - self.parent.min)
			
	
			
			
			if nvalue ~= pMinValue and nvalue >= self.parent.min and nvalue <= self.parent.max then
				if self.parent.OnMinValueChanged then
					self.parent:OnMinValueChanged(self.parent.minValue)
				end
			end
			
		elseif self.buttontype == 'max' then
		
			if nvalue > self.parent.max then
				nvalue = self.parent.max
			end
			
			if nvalue < self.parent.minValue then
				nvalue = self.parent.minValue -- может плюс самое маленькое допустимое число ?!!!
			end
			
			self.parent.maxValue = nvalue
		
		
			-- корректируем координату бегунка
		
			self.staticx = self.width + (self.parent.width - 2 * self.width) * (nvalue - self.parent.min) / (self.parent.max - self.parent.min)
		
		
			if nvalue ~= pMaxValue and nvalue >= self.parent.min and nvalue <= self.parent.max then
				if self.parent.OnMinValueChanged then
					self.parent:OnMaxValueChanged(self.parent.maxValue)
				end
			end
		
		end
		
		loveframes.downobject = self
	end
	
	-- тут ограничивается перемещение ползунка допустимыми пределами
	if slidetype == "horizontal" then
		
		if (self.staticx + self.width) > self.parent.width then
			self.staticx = self.parent.width - self.width
		end
		
		if self.staticx < 0 then
			self.staticx = 0
		end
	end
--[[	
	if slidetype == "vertical" then
		if (self.staticy + self.height) > self.parent.height then
			self.staticy = self.parent.height - self.height
		end		
		if self.staticy < 0 then
			self.staticy = 0
		end
	end
]]	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function newobject:draw()
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawSliderButton or skins[defaultskin].DrawSliderButton
	local draw = self.Draw
	local drawcount = loveframes.drawcount
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	
	if hover and button == "l" then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
		self.down = true
		self.dragging = true
		self.startx = self.staticx
		self.clickx = x
		self.starty = self.staticy
		self.clicky = y
		loveframes.downobject = self
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local down = self.down
	local dragging = self.dragging
	
	if dragging then
		local parent = self.parent
		local onrelease = parent.OnRelease
		if onrelease then
			onrelease(parent)
		end
	end
	
	self.down = false
	self.dragging = false

end

--[[---------------------------------------------------------
	- func: MoveToX(x)
	- desc: moves the object to the specified x position
--]]---------------------------------------------------------
function newobject:MoveToX(x)

	self.staticx = x
	
end

--[[---------------------------------------------------------
	- func: MoveToY(y)
	- desc: moves the object to the specified y position
--]]---------------------------------------------------------
function newobject:MoveToY(y)

	self.staticy = y
	
end
