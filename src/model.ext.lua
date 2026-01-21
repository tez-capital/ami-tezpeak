local download_urls = am.app.get_model("DOWNLOAD_URLS")
local arc_download_url = download_urls.arc

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
