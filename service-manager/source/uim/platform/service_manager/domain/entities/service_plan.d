module uim.platform.service_manager.domain.entities.service_plan;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServicePlan {
    mixin TenantEntity!(ServicePlanId);

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

    Json toJson() const {
        return entityToJson
            .set("offeringId", offeringId)
            .set("name", name)
            .set("description", description)
            .set("catalogName", catalogName)
            .set("pricing", pricing.to!string())
            .set("free", free)
            .set("bindable", bindable)
            .set("planUpdateable", planUpdateable)
            .set("maxInstances", maxInstances)
            .set("schemas", schemas)
            .set("metadata", metadata);
    }
}
