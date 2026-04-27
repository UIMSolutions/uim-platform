/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.app_versions;

import uim.platform.html_repository.domain.ports.repositories.app_versions;
import uim.platform.html_repository.domain.entities.app_version;
import uim.platform.html_repository.domain.types;

class AppVersionMemoryRepository : TenantRepository!(AppVersion, AppVersionId), AppVersionRepository {

  AppVersion findLatest(HtmlAppId appId) {
    AppVersion latest = AppVersion.init;
    bool found = false;
    foreach (e; findAll) {
      if (e.appId == appId) {
        if (!found || e.createdAt > latest.createdAt) {
          latest = e;
          found = true;
        }
      }
    }
    return latest;
  }

  size_t countByApp(HtmlAppId appId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.appId == appId) count++;
    }
    return count;
  }
  AppVersion[] filterByApp(AppVersion[] versions, HtmlAppId appId) {
    return versions.filter!(v => v.appId == appId).array;
  }
  AppVersion[] findByApp(HtmlAppId appId) {
    return filterByApp(findAll, appId);
  }
  void removeByApp(HtmlAppId appId) {
    findByApp(appId).each!(v => remove(v.id));
  }

  size_t countByStatus(HtmlAppId appId, VersionStatus status) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.appId == appId && e.status == status) count++;
    }
    return count;
  }
  AppVersion[] filterByStatus(AppVersion[] versions, HtmlAppId appId, VersionStatus status) {
    return versions.filter!(v => v.appId == appId && v.status == status).array;
  } 
  AppVersion[] findByStatus(HtmlAppId appId, VersionStatus status) {
    return filterByStatus(findAll, appId, status);
  }
  void removeByStatus(HtmlAppId appId, VersionStatus status) {
    findByStatus(appId, status).each!(v => remove(v.id));
  }

}
