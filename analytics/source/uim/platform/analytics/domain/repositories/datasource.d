module uim.platform.analytics.domain.repositories.datasource;

import uim.platform.analytics.domain.entities.datasource;
import uim.platform.analytics.domain.values.common;

interface DataSourceRepository {
    DataSource findById(EntityId id);
    DataSource[] findAll();
    void save(DataSource ds);
    void remove(EntityId id);
}
