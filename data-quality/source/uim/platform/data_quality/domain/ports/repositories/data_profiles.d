/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.ports.repositories.data_profiles;

// import uim.platform.data_quality.domain.entities.data_profile;
import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
/// Port for persisting data profiling results.
interface DataProfileRepository : ITenantRepository!(DataProfile, DataProfileId) {
  DataProfile findLatestByDataset(TenantId tenantId, DatasetId datasetId);

  size_t countByDataset(TenantId tenantId, DatasetId datasetId);
  DataProfile[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void removeByDataset(TenantId tenantId, DatasetId datasetId);

}
