module domain.ports.system_instance_repository;

import domain.entities.system_instance;
import domain.types;

/// Port: outgoing - system instance persistence.
interface SystemInstanceRepository
{
    SystemInstance* findById(SystemInstanceId id);
    SystemInstance[] findByTenant(TenantId tenantId);
    SystemInstance* findByName(TenantId tenantId, string name);
    SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status);
    void save(SystemInstance instance);
    void update(SystemInstance instance);
    void remove(SystemInstanceId id);
}
