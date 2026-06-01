/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.repositories.planning;
// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

interface PlanningRepository : ITenantRepository!(PlanningModel, PlanningModelId) {

  size_t countByDataset(TenantId tenantId, DatasetId datasetId);
  PlanningModel[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void removeByDataset(TenantId tenantId, DatasetId datasetId);

  size_t countByStatus(TenantId tenantId, PlanningStatus status);
  PlanningModel[] findByStatus(TenantId tenantId, PlanningStatus status);
  void removeByStatus(TenantId tenantId, PlanningStatus status);

  size_t countByVersion(TenantId tenantId, PlanningVersion version_);
  PlanningModel[] findByVersion(TenantId tenantId, PlanningVersion version_);
  void removeByVersion(TenantId tenantId, PlanningVersion version_);

  size_t countByVersionType(TenantId tenantId, VersionType versionType);
  PlanningModel[] findByVersionType(TenantId tenantId, VersionType versionType);
  void removeByVersionType(TenantId tenantId, VersionType versionType);

}
