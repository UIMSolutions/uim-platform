module uim.platform.analytics.app.usecases.predictions;

import uim.platform.analytics.domain.entities.prediction;
import uim.platform.analytics.domain.repositories.prediction;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.app.dto.prediction;
import std.conv : to;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class PredictionUseCases {
    private PredictionRepository repo;

    this(PredictionRepository repo) {
        this.repo = repo;
    }

    PredictionResponse create(CreatePredictionRequest req) {
        PredictionType pt;
        try {
            pt = req.predictionType.to!PredictionType;
        } catch (Exception) {
            pt = PredictionType.Regression;
        }
        auto cfg = PredictionConfig(req.targetColumn, req.featureColumns);
        auto p = Prediction.create(req.name, req.description, req.datasetId, pt, cfg, req.userId);
        repo.save(p);
        return PredictionResponse.fromEntity(p);
    }

    PredictionResponse getById(string id) {
        return PredictionResponse.fromEntity(repo.findById(EntityId(id)));
    }

    PredictionResponse[] list() {
        PredictionResponse[] result;
        foreach (p; repo.findAll())
            result ~= PredictionResponse.fromEntity(p);
        return result;
    }

    PredictionResponse train(string id) {
        auto p = repo.findById(EntityId(id));
        if (p is null) return PredictionResponse.init;
        p.markTraining();
        // Simulated training result
        p.markReady(PredictionResult(0.85, 12.5, 0.95, "", "Model trained successfully"));
        repo.save(p);
        return PredictionResponse.fromEntity(p);
    }

    void remove(string id) {
        repo.remove(EntityId(id));
    }
}
