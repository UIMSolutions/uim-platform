module uim.platform.portal.domain.entities.section;

import uim.platform.portal.domain.types;

/// A section within a page — groups tiles together.
struct Section
{
    SectionId id;
    PageId pageId;
    TenantId tenantId;
    string title;
    TileId[] tileIds;
    int sortOrder;
    bool visible = true;
    int columns = 4; // grid columns
    long createdAt;
    long updatedAt;
}
