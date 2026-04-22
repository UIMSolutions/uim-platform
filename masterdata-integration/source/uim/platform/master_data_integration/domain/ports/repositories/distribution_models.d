/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.distribution_models;

import uim.platform.master_data_integration.domain.entities.distribution_model;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — distribution model persistence.
interface DistributionModelRepository : ITenantRepository!(DistributionModel, DistributionModelId) {

  size_t countByStatus(TenantId tenantId, DistributionModelStatus status);
  DistributionModel[] findByStatus(TenantId tenantId, DistributionModelStatus status);
  void removeByStatus(TenantId tenantId, DistributionModelStatus status);

  size_t countBySourceClient(TenantId tenantId, ClientId sourceClientId);
  DistributionModel[] findBySourceClient(TenantId tenantId, ClientId sourceClientId);
  void removeBySourceClient(TenantId tenantId, ClientId sourceClientId);

}
