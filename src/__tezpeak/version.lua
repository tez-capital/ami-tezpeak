print("ami-tezpeak: " .. am.app.get_version())
local handle <close> = io.popen("bin/tezpeak --version", "r")
if handle ~= nil then
	local version = handle:read("*a")
	print("tezpeak: ".. version)
end