module analytics.domain.repositories.data_source_repository;

import analytics.domain.entities.data_source;
import analytics.domain.values.common;

interface DataSourceRepository {
    DataSource findById(EntityId id);
    DataSource[] findAll();
    void save(DataSource ds);
    void remove(EntityId id);
}
