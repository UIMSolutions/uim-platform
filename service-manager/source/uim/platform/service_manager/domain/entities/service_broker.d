module uim.platform.service_manager.domain.entities.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceBroker {
    mixin TenantEntity!(ServiceBrokerId);

    string name;
    string description;
    string brokerUrl;
    ServiceBrokerStatus status = ServiceBrokerStatus.active;
    long lastCatalogFetch;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("brokerUrl", brokerUrl)
            .set("status", status.to!string())
            .set("lastCatalogFetch", lastCatalogFetch);
    }
}
