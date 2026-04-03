/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.app_version_memory_repository;

import uim.platform.html_repository.domain.ports.app_version_repository;
import uim.platform.html_repository.domain.entities.app_version;
import uim.platform.html_repository.domain.types;

class AppVersionMemoryRepository : AppVersionRepository {
  private AppVersion[] store;

  AppVersion findById(AppVersionId id) {
    foreach (e; store) {
      if (e.id == id) return e;
    }
    return AppVersion.init;
  }

  AppVersion findLatest(HtmlAppId appId) {
    AppVersion latest = AppVersion.init;
    bool found = false;
    foreach (e; store) {
      if (e.appId == appId) {
        if (!found || e.createdAt > latest.createdAt) {
          latest = e;
          found = true;
        }
      }
    }
    return latest;
  }

  AppVersion[] findByApp(HtmlAppId appId) {
    AppVersion[] result;
    foreach (e; store) {
      if (e.appId == appId) result ~= e;
    }
    return result;
  }

  AppVersion[] findByStatus(HtmlAppId appId, VersionStatus status) {
    AppVersion[] result;
    foreach (e; store) {
      if (e.appId == appId && e.status == status) result ~= e;
    }
    return result;
  }

  AppVersion[] findByTenant(TenantId tenantId) {
    AppVersion[] result;
    foreach (e; store) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  void save(AppVersion ver) {
    store ~= ver;
  }

  void update(AppVersion ver) {
    foreach (i, e; store) {
      if (e.id == ver.id) {
        store[i] = ver;
        return;
      }
    }
  }

  void remove(AppVersionId id) {
    AppVersion[] result;
    foreach (e; store) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  long countByApp(HtmlAppId appId) {
    long count = 0;
    foreach (e; store) {
      if (e.appId == appId) count++;
    }
    return count;
  }

  long countByTenant(TenantId tenantId) {
    long count = 0;
    foreach (e; store) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }
}
