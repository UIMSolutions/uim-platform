module uim.platform.analytics.domain.repositories.datasource;

import analytics.domain.entities.datasource;
import analytics.domain.values.common;

interface DataSourceRepository {
    DataSource findById(EntityId id);
    DataSource[] findAll();
    void save(DataSource ds);
    void remove(EntityId id);
}
