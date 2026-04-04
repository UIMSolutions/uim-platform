/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.change_logs;

import uim.platform.master_data_integration.domain.entities.change_log_entry;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — change log persistence.
interface ChangeLogRepository {
  ChangeLogEntry findById(ChangeLogEntryId id);
  ChangeLogEntry[] findByTenant(TenantId tenantId);
  ChangeLogEntry[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId);
  ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category);
  ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken);
  ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp);
  void save(ChangeLogEntry entry);
  void remove(ChangeLogEntryId id);
}
