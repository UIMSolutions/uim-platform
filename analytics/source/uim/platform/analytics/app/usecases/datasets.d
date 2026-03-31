module uim.platform.analytics.app.usecases.datasets;

import uim.platform.analytics.domain.entities.dataset;
import uim.platform.analytics.domain.repositories.dataset;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.app.dto.dataset;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class DatasetUseCases {
    private DatasetRepository repo;

    this(DatasetRepository repo) {
        this.repo = repo;
    }

    DatasetResponse create(CreateDatasetRequest req) {
        auto ds = Dataset.create(req.name, req.description, req.dataSourceId, req.userId);
        repo.save(ds);
        return DatasetResponse.fromEntity(ds);
    }

    DatasetResponse getById(string id) {
        return DatasetResponse.fromEntity(repo.findById(EntityId(id)));
    }

    DatasetResponse[] list() {
        DatasetResponse[] result;
        foreach (d; repo.findAll())
            result ~= DatasetResponse.fromEntity(d);
        return result;
    }

    void remove(string id) {
        repo.remove(EntityId(id));
    }
}
