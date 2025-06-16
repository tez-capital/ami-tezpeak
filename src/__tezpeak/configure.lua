local ok, err = fs.mkdirp("data")
ami_assert(ok, "failed to create data directory - " .. tostring(err))

--// NOTE: we do not use lingering now - we use root systemd instance
-- --- enable linger if not root
-- if user ~= "root" then
-- 	local ok, result = proc.safe_exec("loginctl show-user ".. user .. " --property=Linger=yes", { stdout = "pipe" })
-- 	local stdout = result.stdout_stream:read("a") or ""
-- 	if not ok or result.exit_code ~= 0 or stdout == ""  then
-- 		log_info("Enabling linger for " .. user .. "...")
-- 		local ok, _, exit_code = os.execute("loginctl enable-linger ".. user)
-- 		assert(ok and exit_code == 0, "failed to enable linger for " .. user .. " - " .. tostring(exit_code))
-- 	end
-- end

local service_manager = require"__xtz.service-manager"
local services = require"__tezpeak.services"
service_manager.remove_services(services.cleanup_names) -- cleanup past install
service_manager.install_services(services.active)
log_success(am.app.get("id") .. " services configured")

-- adjust data directory permissions
require"__xtz.base_utils".setup_file_ownership()

