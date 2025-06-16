local service_manager = require"__xtz.service-manager"
local services = require"__tezpeak.services"

service_manager.start_services(services.active_names)

log_success("tezpeak services successfully started.")