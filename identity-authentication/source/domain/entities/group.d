module uim.platform.identity_authentication.domain.entities.group;

import domain.types;

/// Group entity for organizing users.
struct Group
{
    GroupId id;
    TenantId tenantId;
    string name;
    string description;
    string[] memberUserIds;
    long createdAt;
    long updatedAt;
}
