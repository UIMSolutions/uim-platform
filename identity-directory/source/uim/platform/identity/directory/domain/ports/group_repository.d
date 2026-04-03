module uim.platform.xyz.domain.ports.group_repository;

import uim.platform.xyz.domain.entities.group;
import uim.platform.xyz.domain.types;

/// Port: outgoing — group persistence.
interface GroupRepository
{
    Group findById(GroupId id);
    Group findByDisplayName(TenantId tenantId, string displayName);
    Group[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    Group[] findByMember(string memberId);
    void save(Group group);
    void update(Group group);
    void remove(GroupId id);
    ulong countByTenant(TenantId tenantId);
}
