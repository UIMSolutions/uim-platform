module application.usecases.compute_dashboard;

import domain.types;
import domain.entities.quality_dashboard;
import domain.entities.validation_result;
import domain.entities.data_profile;
import domain.ports.validation_result_repository;
import domain.ports.data_profile_repository;
import domain.services.quality_scorer;
import application.dto;

class ComputeDashboardUseCase {
    private ValidationResultRepository resultRepo;
    private DataProfileRepository profileRepo;
    private QualityScorer scorer;

    this(ValidationResultRepository resultRepo,
        DataProfileRepository profileRepo,
        QualityScorer scorer) {
        this.resultRepo = resultRepo;
        this.profileRepo = profileRepo;
        this.scorer = scorer;
    }

    /// Compute a quality dashboard for a dataset.
    QualityDashboard compute(ComputeDashboardRequest req) {
        auto results = resultRepo.findByDataset(req.tenantId, req.datasetId);
        auto profile = profileRepo.findLatestByDataset(req.tenantId, req.datasetId);

        return scorer.computeDashboard(
            req.tenantId, req.datasetId, req.datasetName,
            results, profile);
    }
}
