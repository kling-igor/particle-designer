# Particle Designer

The Particle Designed is a powerful tool for making particle effects for [LÖVE](http://love2d.org) game engine. Created by inspiration of [**S**uper **P**article **E**ditting and **R**endering **M**achine](https://love2d.org/forums/viewtopic.php?f=5&t=76986)

![Particles Designer](https://raw.github.com/kling-igor/particle-designer/master/screenshot.png)

Using this tool
---------------

All settings from left panel are directly mapped to [LÖVE ParticleSystem](https://love2d.org/wiki/ParticleSystem) properties. Initially it already has predefined values. Just tweak them to satisfy your needs and save somewhere (e.g. to current save directory).
By default tool uses internal image set for particles. To use our own image just put it into project root folder or LÖVE save folder (look for [love.filesystem](https://love2d.org/wiki/love.filesystem)).
On next launch it will be accessible from dropdown menu on tool panel. 

Put produced `.lua` file and particle image somewhere into your project. Use next code to load particle system and bring it to life.

```lua
local initParticleSystem
local particle_settings
local ps

local function loadParticleSystem(file)
    local ok, chunk, result
    ok, chunk = pcall(love.filesystem.load, file)

    if not ok then
    error('The following error happend: '..tostring(chunk))
    else
        ok, particle_settings = pcall(chunk)

        if not ok then
            error('The following error happened: '..tostring(result))
        else
            ps = initParticleSystem(particle_settings)
            ps:setPosition(300 + (love.window.getWidth() - 300) / 2, love.window.getHeight() / 2)
            ps:start() 
        end
    end	
end
```

```lua
function initParticleSystem(particle_settings)
    assert(type(particle_settings) == 'table')

    local particle_system = love.graphics.newParticleSystem(love.graphics.newImage(particle_settings["image"]), particle_settings["buffer_size"]) 
    particle_system:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0 , particle_settings["area_spread_dy"] or 0)
    particle_system:setBufferSize(particle_settings["buffer_size"] or 1)

    local colors = {}
    for i = 1, 8 do 
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or
           particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    particle_system:setColors(unpack(colors))

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
        for i = 1, sizes_i do
            table.insert(sizes, particle_settings["sizes"][i] or 0)
        end
        particle_system:setSizes(unpack(sizes))
    end
    particle_system:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    particle_system:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    particle_system:setSpinVariation(particle_settings["spin_variation"] or 0)
    particle_system:setSpread(math.rad(particle_settings["spread"] or 0))
    particle_system:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, particle_settings["tangential_acceleration_max"] or 0)

    return particle_system
end
```

Or you can put content of particle system settings directly into your code to specified variable and just call 

    ps = initParticleSystem(your_particle_settings)

to make particle system.
