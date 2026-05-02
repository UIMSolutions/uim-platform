module uim.platform.service_manager.domain.entities.service_offering;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceOffering {
    mixin TenantEntity!(ServiceOfferingId);

    ServiceBrokerId brokerId;
    string name;
    string description;
    string catalogName;
    ServiceOfferingStatus status = ServiceOfferingStatus.available;
    ServiceCategory category = ServiceCategory.other;
    bool bindable = true;
    bool instancesRetrievable = true;
    bool bindingsRetrievable = true;
    bool planUpdateable = true;
    string metadata;
    string tags;

    Json toJson() const {
        return entityToJson()
            .set("brokerId", brokerId.value)
            .set("name", name)
            .set("description", description)
            .set("catalogName", catalogName)
            .set("status", status.toString())
            .set("category", category.toString())
            .set("bindable", bindable)
            .set("instancesRetrievable", instancesRetrievable)
            .set("bindingsRetrievable", bindingsRetrievable)
            .set("planUpdateable", planUpdateable)
            .set("metadata", metadata)
            .set("tags", tags);
    }
}
