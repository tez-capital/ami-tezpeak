local platform
local ok, platform_plugin = am.plugin.safe_get("platform")
if ok then ok, platform = platform_plugin.get_platform() end

if not ok then
	log_error("Cannot determine platform!")
	return
end

local download_url = nil
local arc_download_url = nil
local sources = require"__tezpeak/constants".sources

if platform.OS == "unix" then
	download_url = sources["linux-x86_64"]
	arc_download_url = sources["arc-linux-x86_64"]
	if platform.SYSTEM_TYPE:match("[Aa]arch64") then
		download_url = sources["linux-arm64"]
		arc_download_url = sources["arc-linux-arm64"]
	end
end

if download_url == nil then
	log_error("Platform not supported!")
	return
end



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
local wanted_binaries = table.keys(services.tezpeak_service_names)

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
            type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and am.app.get_configuration("SERVICE_CONFIGURATION") or {},
            true
        ),
		TEZBAKE_HOME = am.app.get_configuration("TEZBAKE_HOME", path.normalize(path.combine(tostring(os.cwd()), ".."))),
	},
	{ merge = true, overwrite = true }
)