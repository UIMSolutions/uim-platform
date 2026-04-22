/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.master_data_objects;

import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — master data object persistence.
interface MasterDataObjectRepository : ITenantRepository!(MasterDataObject, MasterDataObjectId) {

  bool existsByGlobalId(TenantId tenantId, string globalId);
  MasterDataObject findByGlobalId(TenantId tenantId, string globalId);
  void removeByGlobalId(TenantId tenantId, string globalId);

  size_t countByCategory(TenantId tenantId, MasterDataCategory category);
  MasterDataObject[] findByCategory(TenantId tenantId, MasterDataCategory category);
  void removeByCategory(TenantId tenantId, MasterDataCategory category);

  size_t countByDataModel(TenantId tenantId, DataModelId dataModelId);
  MasterDataObject[] findByDataModel(TenantId tenantId, DataModelId dataModelId);
  void removeByDataModel(TenantId tenantId, DataModelId dataModelId);

  size_t countBySourceSystem(TenantId tenantId, string sourceSystem);
  MasterDataObject[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  void removeBySourceSystem(TenantId tenantId, string sourceSystem);

}
