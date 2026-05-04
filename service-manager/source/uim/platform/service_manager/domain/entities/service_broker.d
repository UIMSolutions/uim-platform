module uim.platform.service_manager.domain.entities.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/** 
    * Represents a service broker in the service manager domain.
    * A service broker is an entity that provides services to the service manager, allowing it to manage and provision those services.
    * The ServiceBroker struct includes properties such as name, description, broker URL, status, and the timestamp of the last catalog fetch.
    * It also includes a method to convert its data into a JSON format for API responses or storage.
    *
    * @property name The name of the service broker.
    * @property description A brief description of the service broker.
    * @property brokerUrl The URL where the service broker can be accessed.
    * @property status The current status of the service broker (e.g., active, inactive).
    * @property lastCatalogFetch The timestamp of the last time the service catalog was fetched from this broker.
    */  
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
