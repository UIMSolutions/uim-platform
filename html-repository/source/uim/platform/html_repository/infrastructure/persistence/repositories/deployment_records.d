/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.deployment_records;

// import uim.platform.html_repository.domain.ports.repositories.deployment_records;
// import uim.platform.html_repository.domain.entities.deployment_record;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class DeploymentRecordMemoryRepository : TenantRepository!(DeploymentRecord, DeploymentRecordId), IDeploymentRecordRepository {

  size_t countByApp(TenantId tenantId, HtmlAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  DeploymentRecord[] filterByApp(DeploymentRecord[] records, HtmlAppId appId) {
    return records.filter!(r => r.appId == appId).array;
  }

  DeploymentRecord[] findByApp(TenantId tenantId, HtmlAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, HtmlAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

  size_t countByVersion(TenantId tenantId, AppVersionId versionId) {
    return findByVersion(tenantId, versionId).length;
  }

  DeploymentRecord[] filterByVersion(DeploymentRecord[] records, AppVersionId versionId) {
    return records.filter!(r => r.versionId == versionId).array;
  }

  DeploymentRecord[] findByVersion(TenantId tenantId, AppVersionId versionId) {
    return filterByVersion(findByTenant(tenantId), versionId);
  }

  void removeByVersion(TenantId tenantId, AppVersionId versionId) {
    findByVersion(tenantId, versionId).each!(r => remove(r));
  }

  size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  DeploymentRecord[] filterByStatus(DeploymentRecord[] records, DeploymentStatus status) {
    return records.filter!(r => r.status == status).array;
  }

  DeploymentRecord[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    return filterByStatus(findByTenant(tenantId).filter!(r => r.tenantId == tenantId).array, status);
  }

  void removeByStatus(TenantId tenantId, DeploymentStatus status) {
    findByStatus(tenantId, status).each!(r => remove(r));
  }
}
