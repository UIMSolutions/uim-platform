module analytics.infrastructure.persistence.memory.repositories.dataset;

import analytics.domain.entities.dataset;
import analytics.domain.repositories.dataset;
import analytics.domain.values.common;

class InMemoryDatasetRepository : DatasetRepository {
    private Dataset[string] store;

    Dataset findById(EntityId id) {
        if (auto p = id.value in store) return *p;
        return null;
    }

    Dataset[] findAll() { return store.values; }

    void save(Dataset dataset) { store[dataset.id.value] = dataset; }

    void remove(EntityId id) { store.remove(id.value); }
}
