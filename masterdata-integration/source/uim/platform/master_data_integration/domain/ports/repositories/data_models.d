/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.data_models;

import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — data model/schema persistence.
interface DataModelRepository : ITenantRepository!(DataModel, DataModelId) {

  bool existsByName(TenantId tenantId, string name);
  DataModel findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByCategory(TenantId tenantId, MasterDataCategory category);
  DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category);
  void removeByCategory(TenantId tenantId, MasterDataCategory category);

}
