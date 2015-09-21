--[[
https://love2d.org/wiki/Game_Distribution
https://love2d.org/wiki/love.filesystem.isFused
https://love2d.org/wiki/love.filesystem.getSourceBaseDirectory
https://love2d.org/wiki/love.filesystem
]]

local TSerial = require 'Tserial'
loveframes = require 'loveframes'
require("loveframes-colorpicker.loveframes-colorpicker")
require 'lovefs/lovefs'
require 'lovefs/dialogs'


-- содержит вначале дефолтные значения
-- в процессе тюнинга - актуальные значени
local particle_settings =  {
	radialacc_min = -500,
	linear_acceleration_ymax = 0,
	tangential_acceleration_max = 1,
	area_spread_distribution = "Uniform",
	speed_min = -200,
	buffer_size = 100,
	offsety = 0,
	area_spread_dx = 0,
	area_spread_dy = 0,
	tangential_acceleration_min = 1,
	rotation_min = 0,
	plifetime_min = 1,
	insert_mode = "Bottom",
	speed_max = 200,
	size_variation = 1,
	emission_rate = 100,
	image = "square.png",
	offsetx = 0,
	emitter_lifetime = -1,
	linear_acceleration_xmin = 0,
	spread = 360,
	spin_max = 360,
	linear_acceleration_ymin = -500,
	rotation_max = 360,
	plifetime_max = 3,
	name = "Blue Fire",
	colors = { {32, 128, 222, 0},
			   {64, 128, 222, 32},
				{64, 128, 222, 32},
				{64, 128, 222, 32},
				{32, 32, 128, 0},
				{0, 0, 0, 0},
				{0, 0, 0, 0},
				{0, 0, 0, 0,} 
	},
	direction = 90,
	radialacc_max = 0,
	linear_acceleration_xmax = 0,
	sizes = {1, 1, 0.5, 0.25, 0, 0, 0, 0, },
	spin_min = 0,
	spin_variation = 1}


local filename = ""
local ps = nil -- particle system
local blendMode = 'additive'
local backgroundColor = {0,0,0}
local dirty = false
local filesystem
local rootPanel
---------------------------------------------------------------------------------------------------

function makeDropdownList(parameters)
	
	local y = parameters.y
	
	local label = loveframes.Create("text", parameters.parent)
	label:SetPos(5, y) -- 5,45
	label:SetLinksEnabled(false)
	label:SetText(parameters.label)

	
	local spreadMultichoice = loveframes.Create("multichoice",  parameters.parent)
	spreadMultichoice:SetPos(80, y - 5) -- 5,40
	spreadMultichoice:SetWidth(195 - 20)


	for i = 1, #parameters.values do
		spreadMultichoice:AddChoice(parameters.values[i])
	end
	
	spreadMultichoice:SetChoice(parameters.defaultValue or parameters.values[1])
	
	spreadMultichoice.OnChoiceSelected = function(object, choice)
		-- particle_settings.image = choice
		if parameters.callback and type(parameters.callback) == 'function' then
			parameters.callback(choice)
		end
	end	

	if parameters.tooltip then
		local tooltip = loveframes.Create("tooltip")
		tooltip:SetObject(label)
		tooltip:SetPadding(5)
	--	tooltip:SetFollowObject(true)
	--	tooltip:SetFollowCursor(true)
		tooltip:SetText(parameters.tooltip)
	end
end
---------------------------------------------------------------------------------------------------
function makeSlider(parameters)
	
	local y = parameters.y
	
	local label = loveframes.Create("text", parameters.parent)
	label:SetText(parameters.label)
	label:SetPos(5, y) -- 5, 0

	local slider = loveframes.Create("slider", parameters.parent)
	slider:SetPos(5, y + 15) -- 5, 15
	slider:SetWidth(200 - 20)
	
	
	slider:SetMinMax(parameters.min or 0, parameters.max)
	slider:SetDecimals(parameters.decimals or 0) -- точек после запятой
	slider:SetValue(parameters.defaultValue or 0)
	
	
	local numberbox 
	slider.OnValueChanged = function(object)
--				print("The slider's value changed to : " ..object:GetValue())
		numberbox:SetValue(object:GetValue())
		if parameters.callback and type(parameters.callback) == 'function' then
			parameters.callback(object:GetValue())
		end
	end
--	slider.Update = function(object, dt)
--		object:CenterX()
--	end
	slider.OnRelease = function(object)
--					print("The slider button has been released.")
		end


	numberbox = loveframes.Create("numberbox", parameters.parent)
	numberbox:SetPos(210 - 20, y + 10) -- 210, 10
	numberbox:SetSize(65, 25)

	numberbox:SetIncreaseAmount(parameters.increaseStep or 1)
	numberbox:SetDecreaseAmount(parameters.decreaseStep or 1)
	numberbox:SetMinMax(parameters.min or 0, parameters.max)
	numberbox:SetDecimals(parameters.decimals or 0) -- точек после запятой
	numberbox:SetValue(parameters.defaultValue or 0)
	
	numberbox.OnValueChanged = function(object, value)
--					print("The object's new value is " ..value)
			slider:SetValue(object:GetValue())
			
			if parameters.callback and type(parameters.callback) == 'function' then
				parameters.callback(object:GetValue())
			end
		end




	if parameters.tooltip then
		local tooltip = loveframes.Create("tooltip")
		tooltip:SetObject(label)
		tooltip:SetPadding(5)
		tooltip:SetText(parameters.tooltip)
	end
end
---------------------------------------------------------------------------------------------------
function makeDoubleSlider(parameters)
	
	local y = parameters.y
	
	local label = loveframes.Create("text", parameters.parent)
	label:SetText(parameters.label)
	label:SetPos(5, y - 10) -- 5, 0

	local minNumberbox = nil
	local maxNumberbox = nil

	
	local minCallback = parameters.minCallback
	local maxCallback = parameters.maxCallback

--[[
	local slider = loveframes.Create("slider", parameters.parent)
	slider:SetPos(5, y + 15) -- 5, 15
	slider:SetWidth(200 - 20)
	
	
	slider:SetMinMax(parameters.min or 0, parameters.max)
	slider:SetDecimals(parameters.decimals or 0) -- точек после запятой
	slider:SetValue(parameters.defaultValue or 0)
	
	
	local numberbox 
	slider.OnValueChanged = function(object)
--				print("The slider's value changed to : " ..object:GetValue())
		numberbox:SetValue(object:GetValue())
		if parameters.callback and type(parameters.callback) == 'function' then
			parameters.callback(object:GetValue())
		end
	end
--	slider.Update = function(object, dt)
--		object:CenterX()
--	end
	slider.OnRelease = function(object)
--					print("The slider button has been released.")
		end
]]
	local slider = loveframes.Create("doubleslider", parameters.parent)
	slider:SetPos(75, y + 15)
	slider:SetWidth(130 - 20)
	slider:SetButtonSize(10, 20)
	
    -- пределы
	slider:SetMinMax(parameters.min or 0, parameters.max or 1)
	
	-- значение для максимального бегунка
	slider:SetMaxValue(parameters.defaultMaxValue or 1)
	
	slider:SetDecimals(parameters.decimals or 0)

	-- значение минимального бегунка
	slider:SetMinValue(parameters.defaultMinValue or 0)	

	slider.OnMinValueChanged = function(object)
		
		minNumberbox:SetValue(object:GetMinValue())
		
--		print("The slider's min value changed to : " ..object:GetMinValue())
		if minCallback then
			minCallback(object:GetMinValue())
		end
	end

	slider.OnMaxValueChanged = function(object)
		
		maxNumberbox:SetValue(object:GetMaxValue())
		
--		print("The slider's max value changed to : " ..object:GetMaxValue())
		if maxCallback then
			maxCallback(object:GetMaxValue())
		end
	end



	minNumberbox = loveframes.Create("numberbox", parameters.parent)
	minNumberbox:SetPos(5, y + 10) -- 210, 10
	minNumberbox:SetSize(65, 25)

	minNumberbox:SetIncreaseAmount(parameters.increaseStep or 1)
	minNumberbox:SetDecreaseAmount(parameters.decreaseStep or 1)
	minNumberbox:SetMinMax(parameters.min or 0, parameters.defaultMaxValue)
	minNumberbox:SetDecimals(parameters.decimals or 0) -- точек после запятой
	
	minNumberbox:SetValue(parameters.defaultMinValue or 0)
	
	minNumberbox.OnValueChanged = function(object, value)
--			print("The object's new value is " ..value)
			slider:SetMinValue(object:GetValue())
			
			if minCallback and type(minCallback) == 'function' then
				minCallback(object:GetValue())
			end
		end
	


	maxNumberbox = loveframes.Create("numberbox", parameters.parent)
	maxNumberbox:SetPos(210 - 20, y + 10) -- 210, 10
	maxNumberbox:SetSize(65, 25)

	maxNumberbox:SetIncreaseAmount(parameters.increaseStep or 1)
	maxNumberbox:SetDecreaseAmount(parameters.decreaseStep or 1)
	maxNumberbox:SetMinMax(parameters.defaultMinValue or 0, parameters.max)
	maxNumberbox:SetDecimals(parameters.decimals or 0) -- точек после запятой

	maxNumberbox:SetValue(parameters.defaultMaxValue or 0)
	
	maxNumberbox.OnValueChanged = function(object, value)
--					print("The object's new value is " ..value)
			slider:SetMaxValue(object:GetValue())
			
			if maxCallback and type(maxCallback) == 'function' then
				maxCallback(object:GetValue())
			end
		end


	if parameters.tooltip then
		local tooltip = loveframes.Create("tooltip")
		tooltip:SetObject(label)
		tooltip:SetPadding(5)
		tooltip:SetText(parameters.tooltip)
	end

end
---------------------------------------------------------------------------------------------------
local function saveParticleSystem(filepath)
	
	local path, file, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	
	local tosave = "return "..Tserial.pack(particle_settings, true, true)
	
	
	if love.filesystem.exists(file) then
		print("File "..file.." exists. Will overwrite...")
	end
	
    local success = love.filesystem.write(file, tosave )
    if success then
        print("successfully saved")
		dirty = false
	else
		print("unable to save "..file)
    end	
end
---------------------------------------------------------------------------------------------------


local makeGUI
local initParticleSystem


local function loadParticleSystem(filepath)
	
	local path, file, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	
	local ok, chunk, result
	ok, chunk = pcall( love.filesystem.load, file ) -- load the chunk safely
	
	if not ok then
		print('The following error happend: ' .. tostring(chunk))
	else
		ok, particle_settings = pcall(chunk) -- execute the chunk safely
	 
		if not ok then -- will be false if there is an error
			print('The following error happened: ' .. tostring(result))
		else
			
			rootPanel:Remove()
			rootPanel = nil
			
			ps:reset()
			ps = nil
			ps = initParticleSystem(particle_settings)
			
			ps:setPosition(300 + (love.window.getWidth() - 300) / 2, love.window.getHeight() / 2)

			makeGUI()
	
			ps:start() 

		end
	end	
end
---------------------------------------------------------------------------------------------------
function initParticleSystem(particle_settings)
	assert(type(particle_settings) == 'table')
	
	local particle_system = love.graphics.newParticleSystem(love.graphics.newImage(particle_settings["image"]), particle_settings["buffer_size"]) 
	particle_system:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0 , particle_settings["area_spread_dy"] or 0)
    particle_system:setBufferSize(particle_settings["buffer_size"] or 1)
	
	local colors = {}
    for i = 1, 8 do 
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    particle_system:setColors(unpack(colors))
	
--	ps:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

    particle_system:setDirection(math.rad(particle_settings["direction"] or 0))
    particle_system:setEmissionRate(particle_settings["emission_rate"] or 0)
    particle_system:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
    particle_system:setInsertMode(string.lower(particle_settings["insert_mode"]))
    particle_system:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0, 
										   particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
    
    if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
        particle_system:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
    end
    
    particle_system:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
    particle_system:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
    particle_system:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
    particle_system:setSizeVariation(particle_settings["size_variation"] or 0)
    
    local sizes = {}
    local sizes_i = 1 
    for i = 1, 8 do 
        if particle_settings["sizes"][i] == 0 then
            if i < 8 and particle_settings["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings["sizes"][i] or 0) end
        particle_system:setSizes(unpack(sizes))
    end
    particle_system:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    particle_system:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    particle_system:setSpinVariation(particle_settings["spin_variation"] or 0)
    particle_system:setSpread(math.rad(particle_settings["spread"] or 0))
    particle_system:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, particle_settings["tangential_acceleration_max"] or 0)

	dirty = false

	return particle_system
end
---------------------------------------------------------------------------------------------------
function makeGUI()
	
	do
		local colorPanel = loveframes.Create("panel")
		colorPanel:SetSize(140, 35)
		colorPanel:SetPos(love.window.getWidth() - 140, 0)
		
		local nameLabel = loveframes.Create("text", colorPanel)
		nameLabel:SetPos(10, 10)
		nameLabel:SetText('Background color')
		
		local backgroundColorButton = colorButton{
			parent = colorPanel;
			color = backgroundColor;
			callback = function(color)
				backgroundColor = color
			end
		}
		backgroundColorButton:SetPos(110, 5)
	end

-- MAKING PANEL 
  
	local WIDTH = 290
	local HEIGHT = love.window.getHeight()
  
	rootPanel = loveframes.Create("panel")
	rootPanel:SetSize(WIDTH, HEIGHT)
	rootPanel:SetPos(0, 0)

	
	local list = loveframes.Create("list", rootPanel)
	list:SetPos(0, 0) -- 0, 25
	list:SetSize(WIDTH, HEIGHT)
	list:SetPadding(5)
	list:SetSpacing(10)

	do
		local panel = loveframes.Create("panel")
		panel:SetHeight(35 + 35)
		panel:SetPos(0, 0)
		
		list:AddItem(panel)
		
		local nameLabel = loveframes.Create("text", panel)
		nameLabel:SetPos(5, 10)
		nameLabel:SetLinksEnabled(false)
		nameLabel:SetText('Name')

		local nameTextinput = loveframes.Create("textinput", panel)
		nameTextinput:SetPos(40, 5)
		nameTextinput:SetWidth(215)
		nameTextinput:SetText(particle_settings.name)
		nameTextinput.OnFocusLost = function(object)
				if particle_settings.name ~= object:GetText() then
					dirty = true
					particle_settings.name = object:GetText()
				end
			end
			
			
		local loadButton = loveframes.Create("button", panel)
		loadButton:SetPos(5, 35)
		loadButton:SetWidth(120)
		loadButton:SetText("Load")
		loadButton.OnClick = function(object, x, y)
				
				-- проверять что система в грязном состоянии и предупреждать об этом
				
				local loadForm = loadDialog(filesystem, {'Lua | *.lua', 'All | *.*'})
				loadForm.window:SetModal(true)
				loadForm.onOK = function(filepath)
					loadParticleSystem(filepath)
				end
				
			end
			
		local saveButton = loveframes.Create("button", panel)
		saveButton:SetPos(135, 35)
		saveButton:SetWidth(120)
		saveButton:SetText("Save")
		saveButton.OnClick = function(object, x, y)
				local filename = particle_settings.name:gsub("%s", "_")
				filename = filename..".lua"
				
				local saveForm = saveDialog(filesystem, filename)
				saveForm.window:SetModal(true)
				saveForm.onOK = function(filepath)
						saveParticleSystem(filepath)
				end
			end
	end


	-- particle panel
	do
		local panel = loveframes.Create("panel")
		panel:SetHeight(255)
--[[
		local collapsiblecategory = loveframes.Create("collapsiblecategory", frame)
		collapsiblecategory:SetPos(0, 60)
		collapsiblecategory:SetText("Particle")
		collapsiblecategory:SetObject(panel)
		
		list:AddItem(collapsiblecategory)
]]

		list:AddItem(panel)



		local files = love.filesystem.getDirectoryItems("")
		local images = {}
		if files then
			for k,v in pairs(files) do
				if string.find(v, "^[%w%p]+%.png") then
					images[#images + 1] = v
				end
			end
		end 

		makeDropdownList{
			parent = panel,
			label = "Filename",
			y = 10,
			values = images,
			defaultValue = particle_settings.image,
			callback = function(choice)
					particle_settings.image = choice
					ps:setTexture(love.graphics.newImage(choice))
					dirty = true
				end,
			tooltip = "Sets the image to be used for the particles."
		}

		makeDropdownList{
			parent = panel,
			label = "Blend mode",
			y = 35,
			values = {'additive', 'alpha', 'subtractive', 'multiplicative', 'premultiplied', 'replace'},
			defaultValue = 'alpha',
			callback = function(choice)
					blendMode = choice
					dirty = true
				end,
			tooltip = "Blending mode"
		}

		makeDropdownList{
			parent = panel,
			label = "Insert mode",
			y = 60,
			values = {'top', 'bottom', 'random'},
			defaultValue = particle_settings.insert_mode,
			callback = function(choice)
					particle_settings.insert_mode = choice
					ps:setInsertMode(choice)
					dirty = true
				end,
			tooltip = "How newly created particles are added to the ParticleSystem."
		}
		
		
		local particlesTabs = loveframes.Create("tabs", panel)
		particlesTabs:SetPos(5, 80)
		particlesTabs:SetSize(WIDTH - 30 - 20, 85)
		
		for i = 1,8 do
		    local particlePanel = loveframes.Create("panel")
			particlePanel.Draw = function() 	end
			
			local colorsLabel = loveframes.Create("text", particlePanel)
			colorsLabel:SetPos(5, 5)
			colorsLabel:SetText("Color")
		
			local colorsTooltip = loveframes.Create("tooltip")
			colorsTooltip:SetObject(colorsLabel)
			colorsTooltip:SetPadding(5)
			colorsTooltip:SetText("A color to apply to the particle sprite. The particle system will interpolate between each color\nevenly over the particle's lifetime.")

			local color = {}
			table.insert(color, particle_settings["colors"][i][1] or 0)
			table.insert(color, particle_settings["colors"][i][2] or 0)
			table.insert(color, particle_settings["colors"][i][3] or 0)

			local button = colorButton{
				parent = particlePanel;
				color = color;
				callback = function(color)
					particle_settings["colors"][i][1] = color[1] or 0
					particle_settings["colors"][i][2] = color[2] or 0
					particle_settings["colors"][i][3] = color[3] or 0
					
					local colors = {}
					for i = 1, 8 do 
						if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
							table.insert(colors, particle_settings["colors"][i][1] or 0)
							table.insert(colors, particle_settings["colors"][i][2] or 0)
							table.insert(colors, particle_settings["colors"][i][3] or 0)
							table.insert(colors, particle_settings["colors"][i][4] or 0)
						end
					end
					ps:setColors(unpack(colors))
					
					dirty = true
				end
			}
			button:SetPos(5, 24)
			
			
			local alphaLabel = loveframes.Create("text", particlePanel)
			alphaLabel:SetPos(60, 5)
			alphaLabel:SetText("Alpha")
			
			local alphaLabelTooltip = loveframes.Create("tooltip")
			alphaLabelTooltip:SetObject(alphaLabel)
			alphaLabelTooltip:SetPadding(5)
			alphaLabelTooltip:SetText("Particle transparency: 0 - fully opaque, 255 - fully transparent")
			
			local slider_left_text = loveframes.Create("text", particlePanel)
			slider_left_text:SetText("0")
			slider_left_text:SetPos(40, 25)
		
			local slider_right_text = loveframes.Create("text", particlePanel)
			slider_right_text:SetText("255")
			slider_right_text:SetPos(100, 25)
			
	    	local slider = loveframes.Create("slider", particlePanel)
			slider:SetPos(50, 25)
			slider:SetWidth(50)
			slider:SetButtonSize(10, 20)
			slider:SetDecimals(0) -- точек после запятой
			slider:SetMinMax(0, 255)
			slider:SetValue(particle_settings["colors"][i][4] or 0)
			slider.OnValueChanged = function(object)
					particle_settings["colors"][i][4] = object:GetValue() or 0
					
					local colors = {}
					for i = 1, 8 do 
						if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
							table.insert(colors, particle_settings["colors"][i][1] or 0)
							table.insert(colors, particle_settings["colors"][i][2] or 0)
							table.insert(colors, particle_settings["colors"][i][3] or 0)
							table.insert(colors, particle_settings["colors"][i][4] or 0)
						end
					end
					ps:setColors(unpack(colors))
					
					dirty = true
				end
			
			
			
			local sizeLabel = loveframes.Create("text", particlePanel)
			sizeLabel:SetPos(150, 5)
			sizeLabel:SetText("Size")
			
			local sizeLabelTooltip = loveframes.Create("tooltip")
			sizeLabelTooltip:SetObject(sizeLabel)
			sizeLabelTooltip:SetPadding(5)
			sizeLabelTooltip:SetText("Size by which to scale a particle sprite. 1.0 is normal size.")
			
			local sizeNumberbox = loveframes.Create("numberbox", particlePanel)
			sizeNumberbox:SetPos(150, 20) -- 210, 10
			sizeNumberbox:SetSize(55, 25)
			sizeNumberbox:SetMinMax(0.01, 100)
			sizeNumberbox:SetDecimals(2) -- точек после запятой
			sizeNumberbox:SetIncreaseAmount(0.1)
			sizeNumberbox:SetDecreaseAmount(0.1)
			sizeNumberbox:SetValue(particle_settings.sizes[i] or 1)
			sizeNumberbox.OnValueChanged = function(object, value)
				particle_settings.sizes[i] = object:GetValue()
				ps:setSizes(unpack(particle_settings.sizes))
				
				dirty = true
			end					
			
			particlesTabs:AddTab(tostring(i),  particlePanel, "Particle interpolation " ..tostring(i))
		end

	
		makeSlider{
			parent = panel,
			label = "Size variations",
			y = 170,
			callback = function(value)
					particle_settings.size_variation = value
					ps:setSizeVariation(value)
					
					dirty = true
				end,
			min = 0,
			max = 1,
			defaultValue = particle_settings.size_variation or 1,
			increaseStep = 0.1,
			decreaseStep = 0.1,
			decimals = 2,
			tooltip = "The amount of size variation (0 meaning no variation and\n1 meaning full variation between start and end)."
		}
	
	
		makeDoubleSlider{
			parent = panel,
			label = "Particle lifetime",
			y = 170 + 45,
			minCallback = function(value)
					particle_settings.plifetime_min = value
					ps:setParticleLifetime( particle_settings.plifetime_min, particle_settings.plifetime_max )
					
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.plifetime_max = value
					ps:setParticleLifetime( particle_settings.plifetime_min, particle_settings.plifetime_max )
					
					dirty = true
				end,
			min = 0,
			max = 10,
			defaultMinValue = particle_settings.plifetime_min or 1,
			defaultMaxValue = particle_settings.plifetime_max or 3,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 1,
			tooltip = "Lifetime of the particles"
		}
	end

	-- emitter panel
	do
		local panel = loveframes.Create("panel")
		panel:SetHeight(775)
--[[
		local collapsiblecategory = loveframes.Create("collapsiblecategory", frame)
		collapsiblecategory:SetPos(0, 85)
		collapsiblecategory:SetText("Emitter")
		collapsiblecategory:SetObject(panel)
		
		list:AddItem(collapsiblecategory)
]]
		list:AddItem(panel)


		makeSlider{
			parent = panel,
			label = "Particles",
			y = 0,
			callback = function(value)
					particle_settings.buffer_size = value
					ps:setBufferSize(value)
					
					dirty = true
				end,
			min = 0,
			max = 1000,
			defaultValue = particle_settings.buffer_size or 100,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The max allowed amount of particles in the system"
		}
		
		makeSlider{
			parent = panel,
			label = "Emission Rate",
			y = 45,
			callback = function(value)
					particle_settings.emission_rate  = value
					ps:setEmissionRate(value)
					
					dirty = true
				end,
			min = 1,
			max = 1000,
			defaultValue = particle_settings.emission_rate or 100,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The amount of particles emitted per second."
		}
		
		makeSlider{
			parent = panel,
			label = "Emitter Lifetime",
			y = 45 + 45,
			callback = function(value)
					value = value <= 0 and -1 or value
					particle_settings.emitter_lifetime = value
					ps:setEmitterLifetime(value)
					
					dirty = true
				end,
			min = -1,
			max = 1000,
			defaultValue = particle_settings.emitter_lifetime or -1,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 1,
			tooltip = "How long the particle system should emit particles (if -1 then it emits particles forever)."
		}
		
		makeDropdownList{
			parent = panel,
			label = "Area Spread",
			y = 45 + 45 + 45,
			values = {'none', 'uniform', 'normal'},
			defaultValue = particle_settings.area_spread_distribution or 'none',
			callback = function(choice)
					particle_settings.area_spread_distribution = choice
					ps:setAreaSpread(particle_settings.area_spread_distribution, particle_settings.area_spread_dx, particle_settings.area_spread_dy)
					
					dirty = true
				end,
			tooltip = "Sets area-based spawn parameters for the particles"
		}
		
		
		
		do
			local label = loveframes.Create("text", panel)
			label:SetPos(5, 45 + 45 + 45 + 30) -- 5,45
			label:SetLinksEnabled(false)
			label:SetText("X spawn distance")
			
			local numberbox = loveframes.Create("numberbox", panel)
			numberbox:SetPos(190, 45 + 45 + 45 + 25) -- 210, 10
			numberbox:SetSize(65, 25)
			
			numberbox:SetIncreaseAmount(1)
			numberbox:SetDecreaseAmount(1)
			numberbox:SetMinMax(-1000 , 1000)
			numberbox:SetDecimals(0)
	
			numberbox:SetValue(particle_settings.area_spread_dx or 0)

			numberbox.OnValueChanged = function(object, value)
					particle_settings.area_spread_dx = object:GetValue()
					ps:setAreaSpread(particle_settings.area_spread_distribution, particle_settings.area_spread_dx, particle_settings.area_spread_dy)
					
					dirty = true
				end
	
			local tooltip = loveframes.Create("tooltip")
			tooltip:SetObject(label)
			tooltip:SetPadding(5)
			tooltip:SetText("The maximum spawn distance from the emitter along the x-axis for uniform distribution,\nor the standard deviation along the x-axis for normal distribution.")
		
		end
		
		
		do
			local label = loveframes.Create("text", panel)
			label:SetPos(5, 45 + 45 + 45 + 30 + 30) -- 5,45
			label:SetLinksEnabled(false)
			label:SetText("Y spawn distance")
			
			local numberbox = loveframes.Create("numberbox", panel)
			numberbox:SetPos(190, 45 + 45 + 45 + 25 + 30) -- 210, 10
			numberbox:SetSize(65, 25)
			
			numberbox:SetIncreaseAmount(1)
			numberbox:SetDecreaseAmount(1)
			numberbox:SetMinMax(-1000 , 1000)
			numberbox:SetDecimals(0)			
			
			numberbox:SetValue(particle_settings.area_spread_dy or 0)
				
			numberbox.OnValueChanged = function(object, value)
					particle_settings.area_spread_dy = object:GetValue()
					ps:setAreaSpread(particle_settings.area_spread_distribution, particle_settings.area_spread_dx, particle_settings.area_spread_dy)
					
					dirty = true
				end

			local tooltip = loveframes.Create("tooltip")
			tooltip:SetObject(label)
			tooltip:SetPadding(5)
			tooltip:SetText("The maximum spawn distance from the emitter along the y-axis for uniform distribution,\nor the standard deviation along the y-axis for normal distribution.")
		end
	
		makeSlider{
			parent = panel,
			label = "Direction",
			y = 45 + 45 + 45 + 30 + 30 + 30,
			callback = function(value)
					particle_settings.direction = value
					ps:setDirection(math.rad(value))
					
					dirty = true
				end,
			min = 0,
			max = 360,
			defaultValue = particle_settings.direction or 0,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 1,
			tooltip = "The direction the particles will be emitted in."
		}
		
		makeSlider{
			parent = panel,
			label = "Spread",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40,
			callback = function(value)
					particle_settings.spread = value
					ps:setSpread(math.rad(value))
					
					dirty = true
				end,
			min = 0,
			max = 360,
			defaultValue = particle_settings.spread or 360,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 1,
			tooltip = "The amount of spread for the system"
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Linear speed",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50,
			minCallback = function(value)
					particle_settings.speed_min = value
					ps:setSpeed(particle_settings.speed_min, particle_settings.speed_max)
					
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.speed_max = value
					ps:setSpeed(particle_settings.speed_min, particle_settings.speed_max)
					
					dirty = true
				end,
			min = -1000,
			max = 1000,
			defaultMinValue = particle_settings.speed_min or -100,
			defaultMaxValue = particle_settings.speed_max or 100,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The linear speed of the particles"
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Linear acceleration along x-axis",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50,
			minCallback = function(value)
					particle_settings.linear_acceleration_xmin = value
					
					ps:setLinearAcceleration(particle_settings.linear_acceleration_xmin,
											  particle_settings.linear_acceleration_ymin,
											  particle_settings.linear_acceleration_xmax,
											  particle_settings.linear_acceleration_ymax)
										
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.linear_acceleration_xmax = value
					
					ps:setLinearAcceleration(particle_settings.linear_acceleration_xmin,
											  particle_settings.linear_acceleration_ymin,
											  particle_settings.linear_acceleration_xmax,
											  particle_settings.linear_acceleration_ymax)
										
					dirty = true
				end,
			min = -1000,
			max = 1000,
			defaultMinValue = particle_settings.linear_acceleration_xmin,
			defaultMaxValue = particle_settings.linear_acceleration_xmax,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The linear acceleration (acceleration along the x axis) for particles.\nEvery particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax."
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Linear acceleration along y-axis",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50,
			minCallback = function(value)
					particle_settings.linear_acceleration_ymin = value
					
					ps:setLinearAcceleration(particle_settings.linear_acceleration_xmin,
											  particle_settings.linear_acceleration_ymin,
											  particle_settings.linear_acceleration_xmax,
											  particle_settings.linear_acceleration_ymax)
										
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.linear_acceleration_ymax = value
					
					ps:setLinearAcceleration(particle_settings.linear_acceleration_xmin,
											  particle_settings.linear_acceleration_ymin,
											  particle_settings.linear_acceleration_xmax,
											  particle_settings.linear_acceleration_ymax)
										
					dirty = true
				end,
			min = -1000,
			max = 1000,
			defaultMinValue = particle_settings.linear_acceleration_ymin,
			defaultMaxValue = particle_settings.linear_acceleration_ymax,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The linear acceleration (acceleration along the y axis) for particles.\nEvery particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax."
		}
		
		
		makeDoubleSlider{
			parent = panel,
			label = "Linear damping",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50,
			minCallback = function(value)
					--print("min value:"..value)
					particle_settings.linear_damping_min = value
					ps:setLinearDamping(particle_settings.linear_damping_min, particle_settings.linear_damping_max or 0)
					
					dirty = true
				end,
			maxCallback = function(value)
					--print("max value:"..value)
					particle_settings.linear_damping_max = value
					ps:setLinearDamping(particle_settings.linear_damping_min or 0, particle_settings.linear_damping_max)
					
					dirty = true
				end,
			min = 0,
			max = 500,
			defaultMinValue = particle_settings.linear_damping_min or 0,
			defaultMaxValue = particle_settings.linear_damping_max or 0,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The amount of linear damping (constant deceleration) for particles."
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Tangential acceleration",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50,
			minCallback = function(value)
					particle_settings.tangential_acceleration_min = value
					ps:setTangentialAcceleration(particle_settings.tangential_acceleration_min, particle_settings.tangential_acceleration_max)
					
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.tangential_acceleration_max = value
					ps:setTangentialAcceleration(particle_settings.tangential_acceleration_min, particle_settings.tangential_acceleration_max)
					
					dirty = true
				end,
			min = -10000,
			max = 10000,
			defaultMinValue = particle_settings.tangential_acceleration_min or 0,
			defaultMaxValue = particle_settings.tangential_acceleration_max or 0,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The tangential acceleration (acceleration perpendicular to the particle's direction)."
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Radial acceleration",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50 + 50,
			minCallback = function(value)
					particle_settings.radialacc_min = value
					ps:setTangentialAcceleration(particle_settings.radialacc_min, particle_settings.radialacc_max)
					
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.radialacc_max = value
					ps:setTangentialAcceleration(particle_settings.radialacc_min, particle_settings.radialacc_max)
					
					dirty = true
				end,
			min = -1000,
			max = 1000,
			defaultMinValue = particle_settings.radialacc_min or 0,
			defaultMaxValue = particle_settings.radialacc_max or 0,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The radial acceleration (away from the emitter)"
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Rotation",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50 + 50 + 50,
			minCallback = function(value)
					particle_settings.rotation_min = value
					ps:setRotation(math.rad(particle_settings.rotation_min), math.rad(particle_settings.rotation_max))
					
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.rotation_max = value
					ps:setRotation(math.rad(particle_settings.rotation_min), math.rad(particle_settings.rotation_max))
					
					dirty = true
				end,
			min = 0,
			max = 359,
			defaultMinValue = particle_settings.rotation_min or 0,
			defaultMaxValue = particle_settings.rotation_max or 0,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The rotation of the image upon particle creation."
		}
		
		makeDoubleSlider{
			parent = panel,
			label = "Spin",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 50,
			minCallback = function(value)
					particle_settings.spin_min = value
					ps:setSpin(math.rad(particle_settings.spin_min), math.rad(particle_settings.spin_max))
					
					dirty = true
				end,
			maxCallback = function(value)
					particle_settings.spin_max = value
					ps:setSpin(math.rad(particle_settings.spin_min), math.rad(particle_settings.spin_max))
					
					dirty = true
				end,
			min = -3600,
			max = 3600,
			defaultMinValue = particle_settings.spin_min or 0,
			defaultMaxValue = particle_settings.spin_max or 0,
			increaseStep = 1,
			decreaseStep = 1,
			decimals = 0,
			tooltip = "The spin of the sprite (degrees per second)"
		}
		
		makeSlider{
			parent = panel,
			label = "Spin variation",
			y = 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 45,
			callback = function(value)
					particle_settings.spin_variation = value
					ps:setSpinVariation(value)
					
					dirty = true
				end,
			min = 0,
			max = 1,
			defaultValue = particle_settings.spin_variation or 1,
			increaseStep = 0.1,
			decreaseStep = 0.1,
			decimals = 1,
			tooltip = "The amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end)."
		}
		
		do
			local label = loveframes.Create("text", panel)
			label:SetPos(5, 45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 45 + 40)
			label:SetLinksEnabled(false)
			label:SetText("Realtive rotation")
			
			local checkbox = loveframes.Create("checkbox", panel)
		--	checkbox:SetText("Checkbox")
			checkbox:SetPos(190 + 45,  45 + 45 + 45 + 30 + 30 + 30 + 40 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 50 + 45 + 40)
			checkbox:SetChecked(particle_settings.relative_rotation or false)
			checkbox.OnChanged = function(object, checked)
					particle_settings.relative_rotation = checked
					ps:setRelativeRotation(checked)
					
					dirty = true
				end

			local tooltip = loveframes.Create("tooltip")
			tooltip:SetObject(label)
			tooltip:SetPadding(5)
			tooltip:SetText("Whether particle angles and rotations are relative to their velocities.\nIf enabled, particles are aligned to the angle of their velocities and\nrotate relative to that angle.")
		end
		
	end
	
end

---------------------------------------------------------------------------------------------------
function love.load(arg)
  
	if arg[#arg] == "-debug" then
		require("mobdebug").start()
	end
  
    local sourceBasePath = love.filesystem.getSourceBaseDirectory()
    print("# SourceBaseDirectory: "..sourceBasePath)

    local appDataPath = love.filesystem.getAppdataDirectory()
    print("# AppdataDirectory: "..appDataPath )

    local saveDir = love.filesystem.getSaveDirectory()
    print("# SaveDirectory: "..saveDir)


    local identityDir = love.filesystem.getIdentity()
    print("# IdentityDirectory: "..identityDir)

    local userDir = love.filesystem.getUserDirectory()  
    print("# User Directory: "..userDir)

    local cwd = love.filesystem.getWorkingDirectory()
    print("# Current Working Directory: "..cwd)
	

    local fused = love.filesystem.isFused()
    if fused then
        print("# Fused")
    else
        print("# Not fused")
    end
 
	filesystem = lovefs(love.filesystem.getSaveDirectory()) 
 
	ps = initParticleSystem(particle_settings)
	
    ps:setPosition(300 + (love.window.getWidth() - 300) / 2, love.window.getHeight() / 2)
	
	makeGUI()
	
	ps:start() 
end  
---------------------------------------------------------------------------------------------------
function love.update(dt)
    -- your code
    ps:update(dt)
	
--[[	
	if fsload.selectedFile then
		--img = fsload:loadImage()
		print("Loaded...."..fsload.selectedFile)
		fsload.selectedFile = nil
	end
]]
    loveframes.update(dt)
end
---------------------------------------------------------------------------------------------------
function love.draw()
	love.graphics.setBackgroundColor(unpack(backgroundColor))
	
    -- your code
	love.graphics.setBlendMode(blendMode)
    love.graphics.draw(ps, 0, 0)


	love.graphics.setBlendMode('alpha')
    loveframes.draw()
end
---------------------------------------------------------------------------------------------------

local mousepressed

function love.mousepressed(x, y, button)

    -- your code

	-- если нажали кнопку вза пределами панели
	if button == 'l' and x > 300 then
		mousepressed = true

		ps:start()
	end

    loveframes.mousepressed(x, y, button)

end
---------------------------------------------------------------------------------------------------
function love.mousemoved(x, y, button)

    -- your code

	-- странно, но при удержании кнопка не передается
--	if button == 'l' then
		
	if mousepressed then
--	print(tostring(x)..","..tostring(y))		
		ps:setPosition(x,y)
	end

end
---------------------------------------------------------------------------------------------------
function love.mousereleased(x, y, button)

    -- your code
	mousepressed = false
    loveframes.mousereleased(x, y, button)

end
---------------------------------------------------------------------------------------------------
function love.keypressed(key, unicode)

    -- your code

    loveframes.keypressed(key, unicode)

end
---------------------------------------------------------------------------------------------------
function love.keyreleased(key)

    -- your code

    loveframes.keyreleased(key)

end
---------------------------------------------------------------------------------------------------
function love.textinput(text)

-- your code

  loveframes.textinput(text)
end
---------------------------------------------------------------------------------------------------