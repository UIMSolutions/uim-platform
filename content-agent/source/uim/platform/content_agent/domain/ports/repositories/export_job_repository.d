/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.export_jobs;

import uim.platform.content_agent.domain.entities.export_job;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - export job persistence.
interface ExportJobRepository {
  ExportJob findById(ExportJobId id);
  ExportJob[] findByTenant(TenantId tenantId);
  ExportJob[] findByPackage(ContentPackageId packageId);
  ExportJob[] findByStatus(TenantId tenantId, ExportStatus status);
  void save(ExportJob job);
  void update(ExportJob job);
  void remove(ExportJobId id);
}
