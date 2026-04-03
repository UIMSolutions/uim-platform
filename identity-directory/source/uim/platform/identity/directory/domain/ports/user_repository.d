module uim.platform.xyz.domain.ports.user_repository;

import uim.platform.xyz.domain.entities.user;
import uim.platform.xyz.domain.types;

/// Port: outgoing — user persistence (SCIM 2.0 compliant).
interface UserRepository
{
    User findById(UserId id);
    User findByUserName(TenantId tenantId, string userName);
    User findByExternalId(TenantId tenantId, string externalId);
    User[] findByEmail(TenantId tenantId, string email);
    User[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    User[] findByGroupId(GroupId groupId);
    User[] search(TenantId tenantId, string filter, uint offset = 0, uint limit = 100);
    void save(User user);
    void update(User user);
    void remove(UserId id);
    ulong countByTenant(TenantId tenantId);
}
