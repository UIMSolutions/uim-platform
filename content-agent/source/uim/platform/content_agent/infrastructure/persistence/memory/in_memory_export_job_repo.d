/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.in_memory_export_job_repo;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.export_job;
import uim.platform.content_agent.domain.ports.export_job_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryExportJobRepository : ExportJobRepository
{
  private ExportJob[ExportJobId] store;

  ExportJob findById(ExportJobId id)
  {
    if (auto p = id in store)
      return *p;
    return ExportJob.init;
  }

  ExportJob[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  ExportJob[] findByPackage(ContentPackageId packageId)
  {
    return store.byValue().filter!(e => e.packageId == packageId).array;
  }

  ExportJob[] findByStatus(TenantId tenantId, ExportStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(ExportJob job)
  {
    store[job.id] = job;
  }

  void update(ExportJob job)
  {
    store[job.id] = job;
  }

  void remove(ExportJobId id)
  {
    store.remove(id);
  }
}
