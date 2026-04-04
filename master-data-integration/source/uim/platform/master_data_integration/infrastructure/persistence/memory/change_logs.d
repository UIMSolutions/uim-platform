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
  private ChangeLogEntry[ChangeLogEntryId] store;

  ChangeLogEntry findById(ChangeLogEntryId id)
  {
    if (auto p = id in store)
      return *p;
    return ChangeLogEntry.init;
  }

  ChangeLogEntry[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  ChangeLogEntry[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.objectId == objectId)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.category == category)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken)
  {
    // Find the timestamp associated with the delta token
    long tokenTimestamp = 0;
    foreach (ref entry; store.byValue())
    {
      if (entry.tenantId == tenantId && entry.deltaToken == deltaToken)
      {
        tokenTimestamp = entry.timestamp;
        break;
      }
    }
    // Return all entries after that timestamp
    return store.byValue().filter!(e => e.tenantId == tenantId && e.timestamp > tokenTimestamp)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.timestamp > sinceTimestamp)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  void save(ChangeLogEntry entry)
  {
    store[entry.id] = entry;
  }

  void remove(ChangeLogEntryId id)
  {
    store.remove(id);
  }
}
