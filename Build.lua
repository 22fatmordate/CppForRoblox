-- Asico Language v0.3.0 - C++ style DSL for Roblox Studio using Luau
local Asico = {}

-- Internal State
local usingbasicmain = false
local console = false
local usingValue = false
local service = false

-- Banned words list
local bannedWords = {
	["nigga"] = true
}

-- Memory system (simulate variable scope)
local memory = {
	variables = {},
	functions = {},
	classes = {},
	macros = {},
	includes = {}
}

-- Preprocessor-like features
Asico.define = function(name, value)
	memory.macros[name] = value
end

Asico.include = function(name)
	memory.includes[name] = true
end

-- Package and service setup
Asico.service = function(a)
	if bannedWords[string.lower(a)] then
		error("Access denied: contains banned word.")
	end
	service = true
end

Asico.package = function(packagevalue)
	if packagevalue == 'main' then
		usingbasicmain = true
	end
end

Asico.using = function(space)
	if space == 'dxf' then
		console = true
	elseif space == 'osl' then
		usingValue = true
	end
end

-- Console output
Asico.cout = function(c)
	if not (usingbasicmain and console and service) then
		error("Console output not available. Check your 'service', 'package', or 'using'.")
	end
	if string.sub(c,1,8) == 'cout << ' and string.find(c, 'dxf::endl') then
		local content = string.gsub(c, 'cout << ', '')
		content = string.gsub(content, 'dxf::endl', '')
		print(content)
	else
		error("Syntax error in cout.")
	end
end

-- Math operations
Asico.plus = function(a, b)
	if not usingValue then error("Math library not enabled with 'using osl'") end
	return a + b
end

Asico.minus = function(a, b)
	if not usingValue then error("Math library not enabled") end
	return a - b
end

Asico.mul = function(a, b)
	if not usingValue then error("Math library not enabled") end
	return a * b
end

Asico.div = function(a, b)
	if not usingValue then error("Math library not enabled") end
	if b == 0 then error("Divide by zero") end
	return a / b
end

-- Variable declaration
Asico.var = function(type_, name, value, scope)
	if type_ == "int" or type_ == "float" or type_ == "string" or type_ == "bool" then
		memory.variables[name] = value
	else
		error("Unknown type: " .. tostring(type_))
	end
end

Asico.get = function(name)
	return memory.variables[name]
end

-- Conditions
Asico.ifcheck = function(condition, callback)
	if condition then
		callback()
	end
end

-- Loops
Asico.loop = function(startNum, endNum, callback)
	for i = startNum, endNum do
		callback(i)
	end
end

-- Functions
Asico.func = function(name, callback)
	memory.functions[name] = callback
end

Asico.call = function(name, ...)
	if memory.functions[name] then
		return memory.functions[name](...)
	else
		error("Function '" .. name .. "' not found.")
	end
end

-- Class system (basic OOP with inheritance)
Asico.class = function(className, definition, baseClassName)
	local base = baseClassName and memory.classes[baseClassName] or nil
	local class = base and setmetatable({}, {__index = base}) or {}
	class.__index = class
	memory.classes[className] = class
	definition(class)
end

Asico.new = function(className, ...)
	local class = memory.classes[className]
	if not class then error("Class '" .. className .. "' not defined.") end
	local instance = setmetatable({}, class)
	if instance.constructor then
		instance:constructor(...)
	end
	return instance
end

-- Access modifiers simulation
Asico.public = function(table_, name, value)
	table_[name] = value
end

Asico.private = function(table_, name, value)
	table_["_" .. name] = value
end

Asico.static = function(class, name, value)
	class[name] = value
end

-- Version
Asico.version = function()
	return 'Asico Language First Version!'
end

return Asico
