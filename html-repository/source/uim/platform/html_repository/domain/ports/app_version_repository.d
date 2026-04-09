/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_versions;

import uim.platform.html_repository.domain.entities.app_version;
import uim.platform.html_repository.domain.types;

interface AppVersionRepository {
  AppVersion findById(AppVersionId id);
  AppVersion findLatest(HtmlAppId appId);
  AppVersion[] findByApp(HtmlAppId appId);
  AppVersion[] findByStatus(HtmlAppId appId, VersionStatus status);
  AppVersion[] findByTenant(TenantId tenantId);
  void save(AppVersion ver);
  void update(AppVersion ver);
  void remove(AppVersionId id);
  size_t countByApp(HtmlAppId appId);
  size_t countByTenant(TenantId tenantId);
}
