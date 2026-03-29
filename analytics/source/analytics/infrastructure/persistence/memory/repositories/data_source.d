module analytics.infrastructure.persistence.memory.data_source_repo;

import analytics.domain.entities.data_source;
import analytics.domain.repositories.data_source_repository;
import analytics.domain.values.common;

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
