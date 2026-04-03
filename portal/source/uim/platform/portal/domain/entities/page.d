module uim.platform.xyz.domain.entities.page;

import domain.types;

/// A page within a site; contains sections.
struct Page
{
    PageId id;
    SiteId siteId;
    TenantId tenantId;
    string title;
    string description;
    string alias_; // URL-friendly path
    PageLayout layout = PageLayout.freeform;
    SectionId[] sectionIds;
    RoleId[] allowedRoleIds;
    int sortOrder;
    bool visible = true;
    long createdAt;
    long updatedAt;
}
