module analytics.domain.repositories.widget;

import analytics.domain.entities.widget;
import analytics.domain.values.common;

interface WidgetRepository {
    Widget findById(EntityId id);
    Widget[] findByDataset(EntityId datasetId);
    Widget[] findAll();
    void save(Widget widget);
    void remove(EntityId id);
}
