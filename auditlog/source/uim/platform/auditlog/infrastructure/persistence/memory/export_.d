module uim.platform.auditlog.infrastructure.persistence.memory.export_;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.export_job;
import uim.platform.auditlog.domain.ports.export_job_repository;

// import std.algorithm : filter;
// import std.array : array;

@safe:
class MemoryExportJobRepository : ExportJobRepository
{
  private ExportJob[ExportJobId] store;

  bool existsById(ExportJobId id, TenantId tenantId)
  {
    return (id in store && store[id].tenantId == tenantId);
  }

  ExportJob findById(ExportJobId id, TenantId tenantId)
  {
    if (existsById(id, tenantId))
      return store[id];
    return ExportJob.init;
  }

  ExportJob[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(j => j.tenantId == tenantId).array;
  }

  void save(ExportJob job)
  {
    store[job.id] = job;
  }

  void update(ExportJob job)
  {
    store[job.id] = job;
  }

  void remove(ExportJobId id, TenantId tenantId)
  {
    if (existsById(id, tenantId))
      store.remove(id);
  }
}
