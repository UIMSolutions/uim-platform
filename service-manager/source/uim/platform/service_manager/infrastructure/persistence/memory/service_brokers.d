module uim.platform.service_manager.infrastructure.persistence.memory.service_brokers;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceBrokerRepository : TenantRepository!(ServiceBroker, ServiceBrokerId), ServiceBrokerRepository {

    size_t coundtByStatus(TenantId tenantId, ServiceBrokerStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ServiceBroker[] filterByStatus(ServiceBroker[] brokers, ServiceBrokerStatus status) {
        return brokers.filter!(b => b.status == status).array;
    }

    ServiceBroker[] findByStatus(TenantId tenantId, ServiceBrokerStatus status) {
        return findByTenant(tenantId).filterByStatus!(status);
    }

    void removeByStatus(TenantId tenantId, ServiceBrokerStatus status) {
        findByStatus(tenantId, status).removeAll;
    }
}
