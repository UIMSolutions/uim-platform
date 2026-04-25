module uim.platform.service_manager.domain.ports.repositories.service_broker_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceBrokerRepository : TenantRepository!(ServiceBroker, ServiceBrokerId) {

    size_t countByStatus(TenantId tenantId, ServiceBrokerStatus status);
    ServiceBroker[] filterByStatus(ServiceBroker[] brokers, ServiceBrokerStatus status);
    ServiceBroker[] findByStatus(TenantId tenantId, ServiceBrokerStatus status);
    void removeByStatus(TenantId tenantId, ServiceBrokerStatus status);
    
}
