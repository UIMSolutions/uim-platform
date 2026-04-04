/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.data_models;

import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — data model/schema persistence.
interface DataModelRepository {
  DataModel findById(DataModelId id);
  DataModel[] findByTenant(TenantId tenantId);
  DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category);
  DataModel findByName(TenantId tenantId, string name);
  void save(DataModel model);
  void update(DataModel model);
  void remove(DataModelId id);
}
