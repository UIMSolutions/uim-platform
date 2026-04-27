/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.change_logs;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.change_log_entry;
import uim.platform.master_data_integration.domain.ports.repositories.change_logs;

// import std.algorithm : filter, sort;
// import std.array : array;

class MemoryChangeLogRepository : ChangeLogRepository {

  size_t countByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    return findByObjectId(tenantId, objectId).length;
  }
  ChangeLogEntry[] filterByObjectId(ChangeLogEntry[] entries, MasterDataObjectId objectId, uint offset = 0, uint limit = 0) {
    return (limit == 0)
        ? entries.filter!(e => e.objectId == objectId).skip(offset).array
        : entries.filter!(e => e.objectId == objectId).skip(offset).take(limit).array;
  }
  ChangeLogEntry[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    return filterByObjectId(findByTenant(tenantId), objectId, 0, 0);
  }
  void removeByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    filterByObjectId(findByTenant(tenantId), objectId, 0, 0).each!(e => remove(e));
  }

   size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }
  ChangeLogEntry[] filterByCategory(ChangeLogEntry[] entries, MasterDataCategory category, uint offset = 0, uint limit = 0) {
    return (limit == 0)
        ? entries.filter!(e => e.category == category).skip(offset).array
        : entries.filter!(e => e.category == category).skip(offset).take(limit).array;
  }

  ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category, 0, 0); 
  }

  size_t countSinceTimestamp(TenantId tenantId, long sinceTimestamp) {
    return findSinceTimestamp(tenantId, sinceTimestamp).length;
  }
  ChangeLogEntry[] filterSinceTimestamp(ChangeLogEntry[] entries, long sinceTimestamp, uint offset = 0, uint limit = 0) {
    return (limit == 0)
        ? entries.filter!(e => e.timestamp > sinceTimestamp).skip(offset).array
        : entries.filter!(e => e.timestamp > sinceTimestamp).skip(offset).take(limit).array;
  }
  ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken) {
    // Find the timestamp associated with the delta token
    long tokenTimestamp = 0;
    return filterSinceTimestamp(findByTenant(tenantId), 0, 0):
    }
    // Return all entries after that timestamp
    return findAll()r!(e => e.tenantId == tenantId && e.timestamp > tokenTimestamp)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp) {
    return findAll()r!(e => e.tenantId == tenantId && e.timestamp > sinceTimestamp)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

}
