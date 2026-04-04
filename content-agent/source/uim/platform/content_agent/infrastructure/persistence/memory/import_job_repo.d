/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.in_memory_import_job_repo;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.import_job;
import uim.platform.content_agent.domain.ports.repositories.import_jobs;

// import std.algorithm : filter;
// import std.array : array;

class MemoryImportJobRepository : ImportJobRepository {
  private ImportJob[ImportJobId] store;

  ImportJob findById(ImportJobId id)
  {
    if (auto p = id in store)
      return *p;
    return ImportJob.init;
  }

  ImportJob[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  ImportJob[] findByPackage(ContentPackageId packageId)
  {
    return store.byValue().filter!(e => e.packageId == packageId).array;
  }

  ImportJob[] findByStatus(TenantId tenantId, ImportStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(ImportJob job)
  {
    store[job.id] = job;
  }

  void update(ImportJob job)
  {
    store[job.id] = job;
  }

  void remove(ImportJobId id)
  {
    store.remove(id);
  }
}
