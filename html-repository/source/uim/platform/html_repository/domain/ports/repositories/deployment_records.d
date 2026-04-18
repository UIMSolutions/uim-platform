/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.deployment_records;

import uim.platform.html_repository.domain.entities.deployment_record;
import uim.platform.html_repository.domain.types;

interface DeploymentRecordRepository {
  bool existsById(DeploymentRecordId id);
  DeploymentRecord findById(DeploymentRecordId id);

  size_t countByTenant(TenantId tenantId);
  DeploymentRecord[] findByTenant(TenantId tenantId);

  DeploymentRecord[] findByApp(HtmlAppId appId);
  DeploymentRecord[] findByVersion(AppVersionId versionId);
  DeploymentRecord[] findByStatus(TenantId tenantId, DeploymentStatus status);

  void save(DeploymentRecord record);
  void update(DeploymentRecord record);
  void remove(DeploymentRecordId id);
}
