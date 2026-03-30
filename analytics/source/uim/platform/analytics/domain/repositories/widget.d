module uim.platform.analytics.domain.repositories.widget;

import uim.platform.analytics.domain.entities.widget;
import uim.platform.analytics.domain.values.common;

interface WidgetRepository {
    Widget findById(EntityId id);
    Widget[] findByDataset(EntityId datasetId);
    Widget[] findAll();
    void save(Widget widget);
    void remove(EntityId id);
}
