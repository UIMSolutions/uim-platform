module uim.platform.analytics.infrastructure.persistence.memory.repositories.datasource;

import uim.platform.analytics.domain.entities.datasource;
import uim.platform.analytics.domain.repositories.datasource;
import uim.platform.analytics.domain.values.common;

class InMemoryDataSourceRepository : DataSourceRepository {
    private DataSource[string] store;

    DataSource findById(EntityId id) {
        if (auto p = id.value in store) return *p;
        return null;
    }

    DataSource[] findAll() { return store.values; }

    void save(DataSource ds) { store[ds.id.value] = ds; }

    void remove(EntityId id) { store.remove(id.value); }
}
