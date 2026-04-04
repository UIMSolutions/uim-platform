/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.master_data_objects;

import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — master data object persistence.
interface MasterDataObjectRepository {
  MasterDataObject findById(MasterDataObjectId id);
  MasterDataObject[] findByTenant(TenantId tenantId);
  MasterDataObject[] findByCategory(TenantId tenantId, MasterDataCategory category);
  MasterDataObject[] findByDataModel(TenantId tenantId, DataModelId dataModelId);
  MasterDataObject[] findBySourceSystem(TenantId tenantId, string sourceSystem);
  MasterDataObject findByGlobalId(TenantId tenantId, string globalId);
  void save(MasterDataObject obj);
  void update(MasterDataObject obj);
  void remove(MasterDataObjectId id);
}
