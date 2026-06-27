/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.change_logs;

// import uim.platform.master_data_integration.domain.entities.change_log_entry;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:

/// Port: outgoing — change log persistence.
interface ChangeLogRepository : ITentRepository!(ChangeLogEntry, ChangeLogEntryId) {

  size_t countByObject(TenantId tenantId, MasterDataObjectId objectId);
  ChangeLogEntry[] findByObject(TenantId tenantId, MasterDataObjectId objectId);
  void removeByObject(TenantId tenantId, MasterDataObjectId objectId);

  size_t countByCategory(TenantId tenantId, MasterDataCategory category);
  ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category);
  void removeByCategory(TenantId tenantId, MasterDataCategory category);

  size_t countSinceDeltaToken(TenantId tenantId, string deltaToken);
  ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken);
  void removeSinceDeltaToken(TenantId tenantId, string deltaToken);

  size_t countSinceTimestamp(TenantId tenantId, long sinceTimestamp);
  ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp);
  void removeSinceTimestamp(TenantId tenantId, long sinceTimestamp);

}
