module uim.platform.identity_authentication.domain.ports.group;

import domain.entities.group;
import domain.types;

/// Port: outgoing — group persistence.
interface GroupRepository
{
    Group findById(GroupId id);
    Group[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(Group group);
    void update(Group group);
    void remove(GroupId id);
}
