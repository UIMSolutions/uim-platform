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
interface IAppVersionRepository : ITenantRepository!(AppVersion, AppVersionId) {
  
  // bool existsLatest(TenantId tenantId, HtmlAppId appId);
  AppVersion findLatest(TenantId tenantId, HtmlAppId appId);
  void removeLatest(TenantId tenantId, HtmlAppId appId);
  
  size_t countByApp(TenantId tenantId, HtmlAppId appId);
  AppVersion[] findByApp(TenantId tenantId, HtmlAppId appId);
  void removeByApp(TenantId tenantId, HtmlAppId appId);

  size_t countByStatus(TenantId tenantId, HtmlAppId appId, VersionStatus status);
  AppVersion[] findByStatus(TenantId tenantId, HtmlAppId appId, VersionStatus status);
  void removeByStatus(TenantId tenantId, HtmlAppId appId, VersionStatus status);
  
}
