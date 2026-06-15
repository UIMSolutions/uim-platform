/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.change_logs;

// import uim.platform.master_data_integration.domain.entities.change_log_entry;
// import uim.platform.master_data_integration.domain.ports.repositories.change_logs;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:

class MemoryChangeLogRepository : ChangeLogRepository {

  // #region ByObject
  size_t countByObject(TenantId tenantId, MasterDataObjectId objectId) {
    return findByObject(tenantId, objectId).length;
  }

  ChangeLogEntry[] filterByObject(ChangeLogEntry[] entries, MasterDataObjectId objectId, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
      ? entries.filter!(e => e.objectId == objectId).skip(offset).array
      : entries.filter!(e => e.objectId == objectId).skip(offset).take(limit).array;
  }

  ChangeLogEntry[] findByObject(TenantId tenantId, MasterDataObjectId objectId) {
    return filterByObject(findByTenant(tenantId), objectId, 0, 0);
  }

  void removeByObject(TenantId tenantId, MasterDataObjectId objectId) {
    filterByObject(findByTenant(tenantId), objectId, 0, 0).each!(e => remove(e));
  }
  // #endregion ByObject

  // #region ByCategory
  size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }

  ChangeLogEntry[] filterByCategory(ChangeLogEntry[] entries, MasterDataCategory category, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
      ? entries.filter!(e => e.category == category).skip(offset).array
      : entries.filter!(e => e.category == category).skip(offset).take(limit).array;
  }

  ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category, 0, 0);
  }

  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    filterByCategory(findByTenant(tenantId), category, 0, 0).each!(e => remove(e));
  }
  // #endregion ByCategory

  // #region SinceDeltaToken
   size_t countSinceDeltaToken(TenantId tenantId, string deltaToken) {
    return findSinceDeltaToken(tenantId, deltaToken).length;
  }

  ChangeLogEntry[] filterSinceDeltaToken(ChangeLogEntry[] entries, string deltaToken, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
      ? entries.filter!(e => e.deltaToken >= deltaToken).skip(offset).array
      : entries.filter!(e => e.deltaToken >= deltaToken).skip(offset).take(limit).array;
  }

  ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken) {
    // Find the timestamp associated with the delta token
    long tokenTimestamp = 0;
    return filterSinceTimestamp(findByTenant(tenantId), deltaToken, 0, 0);
  }

  void removeSinceDeltaToken(TenantId tenantId, string deltaToken) {
    filterSinceDeltaToken(findByTenant(tenantId), deltaToken, 0, 0).each!(e => remove(e));
  }
  // #endregion SinceDeltaToken
    

  size_t countSinceTimestamp(TenantId tenantId, long sinceTimestamp) {
    return findSinceTimestamp(tenantId, sinceTimestamp).length;
  }

  ChangeLogEntry[] filterSinceTimestamp(ChangeLogEntry[] entries, long sinceTimestamp, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
      ? entries.filter!(e => e.timestamp > sinceTimestamp).skip(offset).array
      : entries.filter!(e => e.timestamp > sinceTimestamp).skip(offset).take(limit).array;
  }

  ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp) {
    return findByTenant(tenantId).filter!(e => e.tenantId == tenantId && e.timestamp > sinceTimestamp)
      .array
      .sort!((a, b) => a.timestamp < b.timestamp)
      .array;
  }

  void removeSinceTimestamp(TenantId tenantId, long sinceTimestamp) {
    filterSinceTimestamp(findByTenant(tenantId), sinceTimestamp, 0, 0).each!(e => remove(e));
  }

}
