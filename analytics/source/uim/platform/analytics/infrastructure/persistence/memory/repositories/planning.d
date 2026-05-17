/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.planning;
// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.repositories.planning;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class MemoryPlanningRepository : TenantRepository!(PlanningModel, PlanningModelId), PlanningRepository {
 
  // #region ByDataset
  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(findByTenant(tenantId), datasetId).length;
  }
  PlanningModel[] filterByDataset(PlanningModel[] models, DatasetId datasetId) {
    return models.filter!(m => m.datasetId == datasetId).array;
  }
  PlanningModel[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }
  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(m => remove(m));
  }
  // #endregion ByDataset
 
  // #region ByStatus
  size_t countByStatus(TenantId tenantId, PlanningStatus status) {
    return findByStatus(findByTenant(tenantId), status).length;
  }
  PlanningModel[] filterByStatus(PlanningModel[] models, PlanningStatus status) {
    return models.filter!(m => m.planStatus == status).array;
  }
  PlanningModel[] findByStatus(TenantId tenantId, PlanningStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  } 
  void removeByStatus(TenantId tenantId, PlanningStatus status) {
    findByStatus(tenantId, status).each!(m => remove(m));
  }
  // #endregion ByStatus

  // #region ByVersion
  size_t countByVersion(TenantId tenantId, PlanningVersion version_) {
    return findByVersion(findByTenant(tenantId), version_).length;
  }
  PlanningModel[] filterByVersion(PlanningModel[] models, PlanningVersion version_) {
    return models.filter!(m => m.versions.any!(v => v.id == version_.id)).array;
  }
  PlanningModel[] findByVersion(TenantId tenantId, PlanningVersion version_) {
    return filterByVersion(findByTenant(tenantId), version_);
  }
  void removeByVersion(TenantId tenantId, PlanningVersion version_) {
    findByVersion(tenantId, version_).each!(m => remove(m));
  }
  // #endregion ByVersion

  // #region ByVersionType
  size_t countByVersionType(TenantId tenantId, PlanningVersionType versionType) {
    return findByVersionType(findByTenant(tenantId), versionType).length;
  }
  PlanningModel[] filterByVersionType(PlanningModel[] models, PlanningVersionType versionType) {
    return models.filter!(m => m.versions.any!(v => v.versionType == versionType)).array;
  }
  PlanningModel[] findByVersionType(TenantId tenantId, PlanningVersionType versionType) {
    return filterByVersionType(findByTenant(tenantId), versionType);
  }
  void removeByVersionType(TenantId tenantId, PlanningVersionType versionType) {
    findByVersionType(tenantId, versionType).each!(m => remove(m));
  } 
  // #endregion ByVersionType
  
}
