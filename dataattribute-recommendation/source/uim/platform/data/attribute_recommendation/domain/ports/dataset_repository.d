/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;

interface DatasetRepository : ITenantRepository!(Dataset, DatasetId) {

  bool existsByName(TenantId tenantId, string name);
  Dataset findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByStatus(TenantId tenantId, DatasetStatus status);
  Dataset[] filterByStatus(Dataset[] datasets, DatasetStatus status);
  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status);
  void removeByStatus(TenantId tenantId, DatasetStatus status);

  size_t countByDataType(TenantId tenantId, DataType dataType);
  Dataset[] filterByDataType(Dataset[] datasets, DataType dataType);
  Dataset[] findByDataType(TenantId tenantId, DataType dataType);
  void removeByDataType(TenantId tenantId, DataType dataType);

}
