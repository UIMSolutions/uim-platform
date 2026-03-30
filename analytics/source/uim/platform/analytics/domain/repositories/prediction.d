module uim.platform.analytics.domain.repositories.prediction;

import analytics.domain.entities.prediction;
import analytics.domain.values.common;

interface PredictionRepository {
    Prediction findById(EntityId id);
    Prediction[] findByDataset(EntityId datasetId);
    Prediction[] findAll();
    void save(Prediction prediction);
    void remove(EntityId id);
}
