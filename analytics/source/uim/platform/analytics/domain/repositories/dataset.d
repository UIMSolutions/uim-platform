module uim.platform.analytics.domain.repositories.dataset;

import uim.platform.analytics.domain.entities.dataset;
import uim.platform.analytics.domain.values.common;

interface DatasetRepository {
    Dataset findById(EntityId id);
    Dataset[] findAll();
    void save(Dataset dataset);
    void remove(EntityId id);
}
