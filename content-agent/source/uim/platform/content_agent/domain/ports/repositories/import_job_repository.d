/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.import_jobs;

import uim.platform.content_agent.domain.entities.import_job;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - import job persistence.
interface ImportJobRepository
{
  ImportJob findById(ImportJobId id);
  ImportJob[] findByTenant(TenantId tenantId);
  ImportJob[] findByPackage(ContentPackageId packageId);
  ImportJob[] findByStatus(TenantId tenantId, ImportStatus status);
  void save(ImportJob job);
  void update(ImportJob job);
  void remove(ImportJobId id);
}
