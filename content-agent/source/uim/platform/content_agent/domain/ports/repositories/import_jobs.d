/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.import_jobs;

import uim.platform.content_agent.domain.entities.import_job;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - import job persistence.
interface ImportJobRepository : ITenantRepository!(ImportJob, ImportJobId) {
  size_t countByPackage(ContentPackageId packageId);
  ImportJob[] findByPackage(ContentPackageId packageId);
  void removeByPackage(ContentPackageId packageId);

  size_t countByStatus(TenantId tenantId, ImportStatus status);
  ImportJob[] findByStatus(TenantId tenantId, ImportStatus status);
  void removeByStatus(TenantId tenantId, ImportStatus status);
}
