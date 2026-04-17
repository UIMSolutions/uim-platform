/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioning_jobs;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;

interface ProvisioningJobRepository {
  bool existsById(ProvisioningJobId tenantId, id tenantId);
  ProvisioningJob findById(ProvisioningJobId tenantId, id tenantId);
  
  ProvisioningJob[] findByTenant(TenantId tenantId);
  ProvisioningJob[] findBySource(SourceSystemId sourcetenantId, id tenantId);
  ProvisioningJob[] findByTarget(TargetSystemId targettenantId, id tenantId);
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
  
  void save(ProvisioningJob entity);
  void update(ProvisioningJob entity);
  void remove(ProvisioningJobId tenantId, id tenantId);
}
