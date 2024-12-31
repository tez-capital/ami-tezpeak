local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local ok, uid = fs.safe_getuid(user)
ami_assert(ok, "Failed to get " .. user .. "uid - " .. (uid or ""))

local ok, err = fs.safe_mkdirp("data")
ami_assert(ok, "Failed to create data directory - " .. tostring(err) .. "!")

local backend = am.app.get_configuration("backend", os.getenv("ASCEND_SERVICES") ~= nil and "ascend" or "systemd")

local service_manager = require"__xtz.service-manager"
service_manager = service_manager.with_options({ container = user })

--- enable linger if not root
if user ~= "root" then
	local ok, result = proc.safe_exec("loginctl show-user ".. user .. " --property=Linger=yes", { stdout = "pipe" })
	local stdout = result.stdout_stream:read("a") or ""
	if not ok or result.exit_code ~= 0 or stdout == ""  then
		log_info("Enabling linger for " .. user .. "...")
		local ok, _, exit_code = os.execute("loginctl enable-linger ".. user)
		assert(ok and exit_code == 0, "failed to enable linger for " .. user .. " - " .. tostring(exit_code))
	end
end

local services = require"__tezpeak.services"
services.remove_all_services() -- cleanup past install

for k, v in pairs(services.tezpeak_services) do
	local service_id = k
	local source_file = string.interpolate("${file}.${extension}", {
		file = v,
		extension = backend == "ascend" and "ascend.hjson" or "service"
	})
	local ok, err = service_manager.safe_install_service(source_file, service_id)
	ami_assert(ok, "Failed to install " .. service_id .. ".service " .. (err or ""))
end

log_success(am.app.get("id") .. " services configured")

log_info("Granting access to " .. user .. "(" .. tostring(uid) .. ")...")
local ok, err = fs.chown(os.cwd() or ".", uid, uid, { recurse = true })
ami_assert(ok, "Failed to chown - " .. (err or ""))

