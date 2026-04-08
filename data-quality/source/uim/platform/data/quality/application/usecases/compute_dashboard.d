/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.compute_dashboard;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.quality_dashboard;
// import uim.platform.data.quality.domain.entities.validation_result;
// import uim.platform.data.quality.domain.entities.data_profile;
// import uim.platform.data.quality.domain.ports.repositories.validation_results;
// import uim.platform.data.quality.domain.ports.repositories.data_profiles;
// import uim.platform.data.quality.domain.services.quality_scorer;
// import uim.platform.data.quality.application.dto;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class ComputeDashboardUseCase : UIMUseCase {
  private ValidationResultRepository resultRepo;
  private DataProfileRepository profileRepo;
  private QualityScorer scorer;

  this(ValidationResultRepository resultRepo, DataProfileRepository profileRepo,
      QualityScorer scorer) {
    this.resultRepo = resultRepo;
    this.profileRepo = profileRepo;
    this.scorer = scorer;
  }

  /// Compute a quality dashboard for a dataset.
  QualityDashboard compute(ComputeDashboardRequest req) {
    auto results = resultRepo.findByDataset(req.tenantId, req.datasetId);
    auto profile = profileRepo.findLatestByDataset(req.tenantId, req.datasetId);

    return scorer.computeDashboard(req.tenantId, req.datasetId, req.datasetName, results, profile);
  }
}
