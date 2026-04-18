module uim.platform.service_manager.domain.entities.service_instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceInstance {
    ServiceInstanceId id;
    TenantId tenantId;
    string name;
    ServicePlanId planId;
    ServiceOfferingId offeringId;
    PlatformId platformId;
    ServiceInstanceStatus status = ServiceInstanceStatus.creating;
    string context;
    string parameters;
    string dashboardUrl;
    string maintenanceInfo;
    bool shared = false;
    bool usable = true;
    string labels;
    string createdBy;
    long createdAt;
    long updatedAt;
}
