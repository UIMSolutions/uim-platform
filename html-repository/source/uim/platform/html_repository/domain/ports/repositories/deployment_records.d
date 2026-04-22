/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.deployment_records;

// import uim.platform.html_repository.domain.entities.deployment_record;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface DeploymentRecordRepository : ITenantRepository!(DeploymentRecord, DeploymentRecordId) {

  size_t countByApp(HtmlAppId appId);
  DeploymentRecord[] findByApp(HtmlAppId appId);
  void removeByApp(HtmlAppId appId);

  size_t countByVersion(AppVersionId versionId);
  DeploymentRecord[] findByVersion(AppVersionId versionId);
  void removeByVersion(AppVersionId versionId);

  size_t countByStatus(TenantId tenantId, DeploymentStatus status);
  DeploymentRecord[] findByStatus(TenantId tenantId, DeploymentStatus status);
  void removeByStatus(TenantId tenantId, DeploymentStatus status);

}
