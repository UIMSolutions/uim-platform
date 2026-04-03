module uim.platform.xyz.domain.ports.widget_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.widget;

interface WidgetRepository
{
    Widget[] findByPage(WorkpageId pageId, TenantId tenantId);
    Widget* findById(WidgetId id, TenantId tenantId);
    void save(Widget widget);
    void update(Widget widget);
    void remove(WidgetId id, TenantId tenantId);
}
