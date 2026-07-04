module uim.platform.service_manager.domain.entities.service_instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceInstance {
    mixin TenantEntity!(ServiceInstanceId);
    
    string name;
    ServicePlanId planId;
    ServiceOfferingId offeringId;
    PlatformId platformId;
    ServiceInstanceStatus status = ServiceInstanceStatus.creating;
    string context;
    string parameters;
    string dashboardUrl;
    string maintenanceInfo;
    bool shared_ = false;
    bool usable = true;
    string labels;
    
    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("planId", planId)
            .set("offeringId", offeringId)
            .set("platformId", platformId)
            .set("status", status.to!string())
            .set("context", context)
            .set("parameters", parameters)
            .set("dashboardUrl", dashboardUrl)
            .set("maintenanceInfo", maintenanceInfo)
            .set("shared", shared_)
            .set("usable", usable)
            .set("labels", labels);
    }
}
