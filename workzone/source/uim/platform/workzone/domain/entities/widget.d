module uim.platform.xyz.domain.entities.widget;

import uim.platform.xyz.domain.types;

/// A widget instance placed on a workspace page.
struct Widget
{
    WidgetId id;
    WorkpageId pageId;
    TenantId tenantId;
    string title;
    CardId cardId;           // references an integration card
    AppId appId;             // or references a registered app
    WidgetSize size = WidgetSize.medium;
    int row;
    int col;
    int sortOrder;
    bool visible = true;
    WidgetConfig config;
    long createdAt;
    long updatedAt;
}

/// Per-instance widget configuration.
struct WidgetConfig
{
    string customTitle;
    int maxItems;
    int refreshIntervalSec;
    string filterExpression;
    string[string] parameters;
}
