module analytics.infrastructure.persistence.memory.prediction;

import analytics.domain.entities.prediction;
import analytics.domain.repositories.prediction;
import analytics.domain.values.common;

class InMemoryPredictionRepository : PredictionRepository {
    private Prediction[string] store;

    Prediction findById(EntityId id) {
        if (auto p = id.value in store) return *p;
        return null;
    }

    Prediction[] findByDataset(EntityId datasetId) {
        Prediction[] result;
        foreach (p; store.byValue())
            if (p.datasetId == datasetId) result ~= p;
        return result;
    }

    Prediction[] findAll() { return store.values; }

    void save(Prediction prediction) { store[prediction.id.value] = prediction; }

    void remove(EntityId id) { store.remove(id.value); }
}
