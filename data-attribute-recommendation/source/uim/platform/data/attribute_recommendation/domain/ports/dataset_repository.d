/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.datasets;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.dataset;

interface DatasetRepository
{
  Dataset[] findByTenant(TenantId tenantId);
  Dataset* findById(DatasetId id, TenantId tenantId);
  Dataset* findByName(TenantId tenantId, string name);
  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status);
  Dataset[] findByDataType(TenantId tenantId, DataType dataType);
  void save(Dataset dataset);
  void update(Dataset dataset);
  void remove(DatasetId id, TenantId tenantId);
}
