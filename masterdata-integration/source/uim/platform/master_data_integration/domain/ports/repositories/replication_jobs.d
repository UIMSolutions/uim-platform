/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.replication_jobs;

import uim.platform.master_data_integration.domain.entities.replication_job;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — replication job persistence.
interface ReplicationJobRepository : ITenantRepository!(ReplicationJob, ReplicationJobId) {

  size_t countByStatus(TenantId tenantId, ReplicationJobStatus status);
  ReplicationJob[] findByStatus(TenantId tenantId, ReplicationJobStatus status);
  void removeByStatus(TenantId tenantId, ReplicationJobStatus status);

  size_t countByDistributionModel(TenantId tenantId, DistributionModelId modelId);
  ReplicationJob[] findByDistributionModel(TenantId tenantId, DistributionModelId modelId);
  void removeByDistributionModel(TenantId tenantId, DistributionModelId modelId);

}
