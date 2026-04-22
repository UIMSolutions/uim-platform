/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_versions;

// import uim.platform.html_repository.domain.entities.app_version;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface AppVersionRepository : ITenantRepository!(AppVersion, AppVersionId) {
  
  bool existsLatest(HtmlAppId appId);
  AppVersion findLatest(HtmlAppId appId);
  void removeLatest(HtmlAppId appId);
  
  size_t countByApp(HtmlAppId appId);
  AppVersion[] findByApp(HtmlAppId appId);
  void removeByApp(HtmlAppId appId);

  size_t countByStatus(HtmlAppId appId, VersionStatus status);
  AppVersion[] findByStatus(HtmlAppId appId, VersionStatus status);
  void removeByStatus(HtmlAppId appId, VersionStatus status);
  
}
