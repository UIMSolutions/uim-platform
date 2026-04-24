/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.deployment_record_repository;

import uim.platform.html_repository.domain.ports.repositories.deployment_records;
import uim.platform.html_repository.domain.entities.deployment_record;
import uim.platform.html_repository.domain.types;

class DeploymentRecordMemoryRepository : DeploymentRecordRepository {
  private DeploymentRecord[] store;

  DeploymentRecord findById(DeploymentRecordId id) {
    foreach (e; findAll) {
      if (e.id == id) return e;
    }
    return DeploymentRecord.init;
  }

  DeploymentRecord[] findByApp(HtmlAppId appId) {
    DeploymentRecord[] result;
    foreach (e; findAll) {
      if (e.appId == appId) result ~= e;
    }
    return result;
  }

  DeploymentRecord[] findByVersion(AppVersionId versionId) {
    DeploymentRecord[] result;
    foreach (e; findAll) {
      if (e.versionId == versionId) result ~= e;
    }
    return result;
  }

  DeploymentRecord[] findByTenant(TenantId tenantId) {
    DeploymentRecord[] result;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  DeploymentRecord[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    DeploymentRecord[] result;
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.status == status) result ~= e;
    }
    return result;
  }

  void save(DeploymentRecord record) {
    store ~= record;
  }

  void update(DeploymentRecord record) {
    foreach (i, e; store) {
      if (e.id == record.id) {
        store[i] = record;
        return;
      }
    }
  }

  void remove(DeploymentRecordId id) {
    DeploymentRecord[] result;
    foreach (e; findAll) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }
}
