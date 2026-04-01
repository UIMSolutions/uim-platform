module uim.platform.identity_authentication.domain.entities.group;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Group entity for organizing users.
struct Group {
    GroupId id;
    TenantId tenantId;
    string name;
    string description;
    string[] memberUserIds;
    long createdAt;
    long updatedAt;
}
