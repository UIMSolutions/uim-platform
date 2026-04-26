/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.deployment_record_repository;

import uim.platform.html_repository.domain.ports.repositories.deployment_records;
import uim.platform.html_repository.domain.entities.deployment_record;
import uim.platform.html_repository.domain.types;

class DeploymentRecordMemoryRepository : TenantRepository!(DeploymentRecord, DeploymentRecordId), DeploymentRecordRepository {

  size_t countByApp(HtmlAppId appId) {
    return findByApp(appId).length;
  }

  DeploymentRecord[] filterByApp(DeploymentRecord[] records, HtmlAppId appId) {
    return records.filter!(r => r.appId == appId).array;
  }

  DeploymentRecord[] findByApp(HtmlAppId appId) {
    return filterByApp(findAll(), appId);
  }

  void removeByApp(HtmlAppId appId) {
    findByApp(appId).each!(r => remove(r.id));
  }

  size_t countByVersion(AppVersionId versionId) {
    return findByVersion(versionId).length;
  }

  DeploymentRecord[] filterByVersion(DeploymentRecord[] records, AppVersionId versionId) {
    return records.filter!(r => r.versionId == versionId).array;
  }

  DeploymentRecord[] findByVersion(AppVersionId versionId) {
    return filterByVersion(findAll(), versionId);
  }

  void removeByVersion(AppVersionId versionId) {
    findByVersion(versionId).each!(r => remove(r.id));
  }

  size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  DeploymentRecord[] filterByStatus(DeploymentRecord[] records, DeploymentStatus status) {
    return records.filter!(r => r.status == status).array;
  }

  DeploymentRecord[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    return filterByStatus(findAll().filter!(r => r.tenantId == tenantId).array, status);
  }

  void removeByStatus(TenantId tenantId, DeploymentStatus status) {
    findByStatus(tenantId, status).each!(r => remove(r.id));
  }
}
