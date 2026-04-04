/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.model_configs;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_configuration;

interface ModelConfigRepository
{
  ModelConfiguration[] findByTenant(TenantId tenantId);
  ModelConfiguration* findById(ModelConfigId id, TenantId tenantId);
  ModelConfiguration* findByName(TenantId tenantId, string name);
  ModelConfiguration[] findByDataset(DatasetId datasetId, TenantId tenantId);
  ModelConfiguration[] findByStatus(TenantId tenantId, ModelConfigStatus status);
  void save(ModelConfiguration config);
  void update(ModelConfiguration config);
  void remove(ModelConfigId id, TenantId tenantId);
}
