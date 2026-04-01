module uim.platform.identity_authentication.domain.ports.repositories.group;

// import uim.platform.identity_authentication.domain.entities.group;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — group persistence.
interface GroupRepository {
    Group findById(GroupId id);
    Group[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(Group group);
    void update(Group group);
    void remove(GroupId id);
}
