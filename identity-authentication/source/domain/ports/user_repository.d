module domain.ports.user_repository;

import domain.entities.user;
import domain.types;

/// Port: outgoing — user persistence.
interface UserRepository
{
    User findById(UserId id);
    User findByEmail(TenantId tenantId, string email);
    User findByUserName(TenantId tenantId, string userName);
    User[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    User[] findByGroupId(GroupId groupId);
    void save(User user);
    void update(User user);
    void remove(UserId id);
    ulong countByTenant(TenantId tenantId);
}
