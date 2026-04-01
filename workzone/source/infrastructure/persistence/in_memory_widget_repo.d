module infrastructure.persistence.memory.widget_repo;

import domain.types;
import domain.entities.widget;
import domain.ports.widget_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryWidgetRepository : WidgetRepository
{
    private Widget[WidgetId] store;

    Widget[] findByPage(WorkpageId pageId, TenantId tenantId)
    {
        return store.byValue().filter!(w => w.tenantId == tenantId && w.pageId == pageId).array;
    }

    Widget* findById(WidgetId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    void save(Widget widget) { store[widget.id] = widget; }
    void update(Widget widget) { store[widget.id] = widget; }
    void remove(WidgetId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
