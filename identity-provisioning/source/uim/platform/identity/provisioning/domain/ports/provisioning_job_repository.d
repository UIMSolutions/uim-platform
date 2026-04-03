/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.provisioning_job_repository;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;

interface ProvisioningJobRepository
{
  ProvisioningJob[] findByTenant(TenantId tenantId);
  ProvisioningJob* findById(ProvisioningJobId id, TenantId tenantId);
  ProvisioningJob[] findBySource(SourceSystemId sourceId, TenantId tenantId);
  ProvisioningJob[] findByTarget(TargetSystemId targetId, TenantId tenantId);
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
  void save(ProvisioningJob entity);
  void update(ProvisioningJob entity);
  void remove(ProvisioningJobId id, TenantId tenantId);
}
