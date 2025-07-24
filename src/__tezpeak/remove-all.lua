local service_manager = require"__xtz.service-manager"
local services = require"__tezpeak.services"

service_manager.remove_services(services.cleanup_names)

log_success("tezpeak services successfully removed")