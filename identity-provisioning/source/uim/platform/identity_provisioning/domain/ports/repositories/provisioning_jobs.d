/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.ports.repositories.provisioning_jobs;

// import uim.platform.identity_provisioning.domain.types;
// import uim.platform.identity_provisioning.domain.entities.provisioning_job;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
interface ProvisioningJobRepository : ITenantRepository!(ProvisioningJob, ProvisioningJobId) {

  size_t countBySource(TenantId tenantId, SourceSystemId sourceSystemId);
  ProvisioningJob[] findBySource(TenantId tenantId, SourceSystemId sourceSystemId);
  void removeBySource(TenantId tenantId, SourceSystemId sourceSystemId);

  size_t countByTarget(TenantId tenantId, TargetSystemId targetSystemId);
  ProvisioningJob[] findByTarget(TenantId tenantId, TargetSystemId targetSystemId);
  void removeByTarget(TenantId tenantId, TargetSystemId targetSystemId);

  size_t countByStatus(TenantId tenantId, JobStatus status);
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
  void removeByStatus(TenantId tenantId, JobStatus status);
  
}
