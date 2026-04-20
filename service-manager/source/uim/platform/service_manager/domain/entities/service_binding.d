module uim.platform.service_manager.domain.entities.service_binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceBinding {
    mixin TenantEntity!(ServiceBindingId);

    string name;
    ServiceInstanceId instanceId;
    ServiceBindingStatus status = ServiceBindingStatus.creating;
    string credentials;
    string parameters;
    string bindResource;
    string context;
    string labels;
    
    Json toJson() const {
        return Json.entityToJson()
            .set("name", name)
            .set("instanceId", instanceId.value)
            .set("status", status.toString())
            .set("credentials", credentials)
            .set("parameters", parameters)
            .set("bindResource", bindResource)
            .set("context", context)
            .set("labels", labels);
    }
}
