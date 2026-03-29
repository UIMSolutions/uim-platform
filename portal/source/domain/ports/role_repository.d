module domain.ports.role_repository;

import domain.entities.role;
import domain.types;

/// Port: outgoing — role persistence.
interface RoleRepository
{
    Role findById(RoleId id);
    Role findByName(TenantId tenantId, string name);
    Role[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    Role[] findByUser(string userId);
    void save(Role role);
    void update(Role role);
    void remove(RoleId id);
}
