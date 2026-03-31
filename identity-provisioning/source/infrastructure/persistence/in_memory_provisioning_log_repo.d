module infrastructure.persistence.in_memory_provisioning_log_repo;

import domain.types;
import domain.entities.provisioning_log;
import domain.ports.provisioning_log_repository;

class InMemoryProvisioningLogRepository : ProvisioningLogRepository
{
  private ProvisioningLog[string] store;

  void save(ProvisioningLog entity)
  {
    store[entity.id] = entity;
  }

  void remove(ProvisioningLogId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  void removeByJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  ProvisioningLog* findById(ProvisioningLogId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ProvisioningLog[] findByTenant(TenantId tenantId)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByEntity(string entityId, TenantId tenantId)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.entityId == entityId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByStatus(TenantId tenantId, LogStatus status)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  long countByJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId)
        count++;
    return count;
  }

  long countByJobAndStatus(ProvisioningJobId jobId, TenantId tenantId, LogStatus status)
  {
    long count;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId && e.status == status)
        count++;
    return count;
  }
}
