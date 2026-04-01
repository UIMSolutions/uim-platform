module uim.platform.abap_enviroment.domain.ports.business_role_repository;

import uim.platform.abap_enviroment.domain.entities.business_role;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - business role persistence.
interface BusinessRoleRepository
{
    BusinessRole* findById(BusinessRoleId id);
    BusinessRole[] findBySystem(SystemInstanceId systemId);
    BusinessRole[] findByTenant(TenantId tenantId);
    BusinessRole* findByName(SystemInstanceId systemId, string name);
    void save(BusinessRole role);
    void update(BusinessRole role);
    void remove(BusinessRoleId id);
}
