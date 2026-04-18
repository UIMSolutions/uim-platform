module uim.platform.service_manager.domain.entities.service_offering;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceOffering {
    ServiceOfferingId id;
    TenantId tenantId;
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
    string createdBy;
    long createdAt;
    long updatedAt;
}
