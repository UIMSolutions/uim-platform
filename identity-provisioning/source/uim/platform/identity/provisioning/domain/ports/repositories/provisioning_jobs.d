/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioning_jobs;

// import uim.platform.identity.provisioning.domain.types;
// import uim.platform.identity.provisioning.domain.entities.provisioning_job;
import uim.platform.identity.provisioning;

// mixin(ShowModule!());

@safe:
interface ProvisioningJobRepository : ITenantRepository!(ProvisioningJob, ProvisioningJobId) {

  size_t countBySource(TenantId tenantId, TenantSourceSystemId sourceSystemId);
  ProvisioningJob[] findBySource(TenantId tenantId, TenantSourceSystemId sourceSystemId);
  void removeBySource(TenantId tenantId, TenantSourceSystemId sourceSystemId);

  size_t countByTarget(TenantId tenantId, TenantTargetSystemId targetSystemId);
  ProvisioningJob[] findByTarget(TenantId tenantId, TenantTargetSystemId targetSystemId);
  void removeByTarget(TenantId tenantId, TenantTargetSystemId targetSystemId);

  size_t countByStatus(TenantId tenantId, JobStatus status);
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
  void removeByStatus(TenantId tenantId, JobStatus status);
  
}
