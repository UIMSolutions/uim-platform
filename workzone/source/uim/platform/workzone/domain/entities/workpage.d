module domain.entities.workpage;

import domain.types;

/// A page within a workspace — containers for widgets and content.
struct Workpage
{
    WorkpageId id;
    WorkspaceId workspaceId;
    TenantId tenantId;
    string title;
    string description;
    WidgetId[] widgetIds;
    RoleId[] allowedRoleIds;
    int sortOrder;
    bool visible = true;
    bool isDefault;
    long createdAt;
    long updatedAt;
}
