local download_url = nil
local arc_download_url = nil
local sources = require "__tezpeak/constants".sources

local system_os = am.app.get_model("SYSTEM_OS", "unknown")
local system_distro = am.app.get_model("SYSTEM_DISTRO", "unknown")
local system_type = am.app.get_model("SYSTEM_TYPE", "unknown")

if system_os == "unix" then
	if system_distro == "MacOS" then
		download_url = sources["macos-arm64"]
		arc_download_url = sources["arc-macos-arm64"]
	else
		download_url = sources["linux-x86_64"]
		arc_download_url = sources["arc-linux-x86_64"]
		if system_type:match("[Aa]arch64") then
			download_url = sources["linux-arm64"]
			arc_download_url = sources["arc-linux-arm64"]
		end
	end
end

ami_assert(download_url ~= nil,
	"no download URLs found for the current platform: " .. system_os .. " " .. system_distro .. " " .. system_type)

am.app.set_model(
	{
		DOWNLOAD_URLS = {
			tezpeak = am.app.get_configuration("SOURCE", download_url),
			arc = am.app.get_configuration("ARC_SOURCE", arc_download_url),
		}
	},
	{ merge = true, overwrite = true }
)

local services = require("__tezpeak.services")
local wanted_binaries = table.keys(services.active_names)

if arc_download_url == nil then
	log_warn("arc monitoring not supported on this platform.")
else
	table.insert(wanted_binaries, "arc")
end

am.app.set_model(
	{
		WANTED_BINARIES = wanted_binaries,
		SERVICE_CONFIGURATION = util.merge_tables(
			{
				TimeoutStopSec = 600,
			},
			type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and
			am.app.get_configuration("SERVICE_CONFIGURATION") or {},
			true
		),
		TEZBAKE_HOME = am.app.get_configuration("TEZBAKE_HOME", path.normalize(path.combine(tostring(os.cwd()), ".."))),
	},
	{ merge = true, overwrite = true }
)
