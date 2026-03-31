module uim.platform.analytics.domain.repositories.prediction;

import uim.platform.analytics.domain.entities.prediction;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

interface PredictionRepository {
    Prediction findById(EntityId id);
    Prediction[] findByDataset(EntityId datasetId);
    Prediction[] findAll();
    void save(Prediction prediction);
    void remove(EntityId id);
}
