module domain.ports.widget_repository;

import domain.types;
import domain.entities.widget;

interface WidgetRepository
{
    Widget[] findByPage(WorkpageId pageId, TenantId tenantId);
    Widget* findById(WidgetId id, TenantId tenantId);
    void save(Widget widget);
    void update(Widget widget);
    void remove(WidgetId id, TenantId tenantId);
}
