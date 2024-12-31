local hjson = require"hjson"

local version = os.getenv("VERSION")
if not version then
	os.exit(222)
end
local constants = fs.read_file("./src/__tezpeak/constants.lua")
constants = constants:gsub("tezpeak/releases/download/%d-%.%d-%.%d-[^/]*", "tezpeak/releases/download/" .. version)
fs.write_file("./src/__tezpeak/constants.lua", constants)

local specs_raw = fs.read_file("./src/specs.json")
local specs = hjson.parse(specs_raw)
local package_version = string.split(specs.version, "+", true)[1]
local package_version_patch = tonumber(string.split(package_version, ".", true)[3])
package_version_patch = package_version_patch + 1
package_version = string.split(package_version, ".", true)[1] .. "." .. string.split(package_version, ".", true)[2] .. "." .. package_version_patch
specs.version = package_version .. "+" .. version

fs.write_file("./src/specs.json", hjson.stringify_to_json(specs, { indent = "    " }))

print("VERSION=" .. specs.version)