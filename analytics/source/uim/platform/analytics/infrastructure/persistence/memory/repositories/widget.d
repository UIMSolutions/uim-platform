module uim.platform.analytics.infrastructure.persistence.memory.repositories.widget;

import uim.platform.analytics.domain.entities.widget;
import uim.platform.analytics.domain.repositories.widget;
import uim.platform.analytics.domain.values.common;

class MemoryWidgetRepository : WidgetRepository {
    private Widget[string] store;

    Widget findById(EntityId id) {
        if (auto p = id.value in store) return *p;
        return null;
    }

    Widget[] findByDataset(EntityId datasetId) {
        Widget[] result;
        foreach (w; store.byValue())
            if (w.datasetId == datasetId) result ~= w;
        return result;
    }

    Widget[] findAll() { return store.values; }

    void save(Widget widget) { store[widget.id.value] = widget; }

    void remove(EntityId id) { store.remove(id.value); }
}
