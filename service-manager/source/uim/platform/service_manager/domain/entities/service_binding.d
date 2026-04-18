module uim.platform.service_manager.domain.entities.service_binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceBinding {
    ServiceBindingId id;
    TenantId tenantId;
    string name;
    ServiceInstanceId instanceId;
    ServiceBindingStatus status = ServiceBindingStatus.creating;
    string credentials;
    string parameters;
    string bindResource;
    string context;
    string labels;
    string createdBy;
    long createdAt;
    long updatedAt;
}
