module uim.platform.portal.domain.entities.role;

import uim.platform.portal.domain.types;

/// Role for portal access — controls what content users can see.
struct Role
{
    RoleId id;
    TenantId tenantId;
    string name;
    string description;
    RoleScope scope_ = RoleScope.site;
    string[] userIds;
    string[] groupIds;
    long createdAt;
    long updatedAt;
}
