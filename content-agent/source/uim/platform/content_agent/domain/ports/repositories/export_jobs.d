/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.export_jobs;

// import uim.platform.content_agent.domain.entities.export_job;
// import uim.platform.content_agent.domain.types;

import uim.platform.content_agent;

mixin(ShowModule!());
@safe:
/// Port: outgoing - export job persistence.
interface ExportJobRepository : ITenantRepository!(ExportJob, ExportJobId) {

  // size_t countByFormat(TenantId tenantId, ExportFormat format);
  // ExportJob[] findByFormat(TenantId tenantId, ExportFormat format);
  // void removeByFormat(TenantId tenantId, ExportFormat format);

  size_t countByStatus(TenantId tenantId, ExportStatus status);
  ExportJob[] findByStatus(TenantId tenantId, ExportStatus status);
  void removeByStatus(TenantId tenantId, ExportStatus status);

}
