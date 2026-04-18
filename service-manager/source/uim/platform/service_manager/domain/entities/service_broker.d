module uim.platform.service_manager.domain.entities.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceBroker {
    ServiceBrokerId id;
    TenantId tenantId;
    string name;
    string description;
    string brokerUrl;
    ServiceBrokerStatus status = ServiceBrokerStatus.active;
    long lastCatalogFetch;
    string createdBy;
    long createdAt;
    long updatedAt;
}
