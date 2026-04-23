module uim.platform.service_manager.domain.ports.repositories.service_broker_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceBrokerRepository {
    ServiceBroker[] findByTenant(TenantId tenantId);
    ServiceBroker* findById(TenantId tenantId, ServiceBrokerId id);
    void save(ServiceBroker entity);
    void update(ServiceBroker entity);
    void remove(TenantId tenantId, ServiceBrokerId id);
    ulong countByTenant(TenantId tenantId);
}
