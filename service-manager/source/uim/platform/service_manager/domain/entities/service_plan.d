module uim.platform.service_manager.domain.entities.service_plan;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServicePlan {
    ServicePlanId id;
    TenantId tenantId;
    ServiceOfferingId offeringId;
    string name;
    string description;
    string catalogName;
    ServicePlanPricing pricing = ServicePlanPricing.free;
    bool free = true;
    bool bindable = true;
    bool planUpdateable = true;
    int maxInstances;
    string schemas;
    string metadata;
    string createdBy;
    long createdAt;
    long updatedAt;
}
