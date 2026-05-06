/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioning_jobs;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;

interface ProvisioningJobRepository : ITenantRepository!(ProvisioningJob, ProvisioningJobId) {

  size_t countBySource(SourceSystemId sourcetenantId, id tenantId);
  ProvisioningJob[] findBySource(SourceSystemId sourcetenantId, id tenantId);
  void removeBySource(SourceSystemId sourcetenantId, id tenantId);

  size_t countByTarget(TargetSystemId targettenantId, id tenantId);
  ProvisioningJob[] findByTarget(TargetSystemId targettenantId, id tenantId);
  void removeByTarget(TargetSystemId targettenantId, id tenantId);

  size_t countByStatus(TenantId tenantId, JobStatus status);
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
  void removeByStatus(TenantId tenantId, JobStatus status);
  
}
