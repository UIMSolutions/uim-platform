module uim.platform.identity_authentication.domain.ports.repositories.group;

// import uim.platform.identity_authentication.domain.entities.group;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — group persistence.
interface GroupRepository {
    IdaGroup findById(GroupId id);
    IdaGroup[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(IdaGroup group);
    void update(IdaGroup group);
    void remove(GroupId id);
}
