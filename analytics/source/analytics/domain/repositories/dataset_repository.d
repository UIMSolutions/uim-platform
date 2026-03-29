module analytics.domain.repositories.dataset_repository;

import analytics.domain.entities.dataset;
import analytics.domain.values.common;

interface DatasetRepository {
    Dataset findById(EntityId id);
    Dataset[] findAll();
    void save(Dataset dataset);
    void remove(EntityId id);
}
