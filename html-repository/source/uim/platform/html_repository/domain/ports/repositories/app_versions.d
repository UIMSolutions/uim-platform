/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_versions;

import uim.platform.html_repository.domain.entities.app_version;
import uim.platform.html_repository.domain.types;

interface AppVersionRepository {
  bool existsById(AppVersionId id);
  AppVersion findById(AppVersionId id);

  bool existsLatest(HtmlAppId appId);
  AppVersion findLatest(HtmlAppId appId);
  
  size_t countByApp(HtmlAppId appId);
  AppVersion[] findByApp(HtmlAppId appId);

  size_t countByTenant(TenantId tenantId);
  AppVersion[] findByTenant(TenantId tenantId);
  
  AppVersion[] findByStatus(HtmlAppId appId, VersionStatus status);
  
  void save(AppVersion appVersion);
  void update(AppVersion appVersion);
  void remove(AppVersionId id);
}
