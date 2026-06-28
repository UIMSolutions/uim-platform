/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.query_change_log;

// import uim.platform.master_data_integration.domain.entities.change_log_entry;
// import uim.platform.master_data_integration.domain.ports.repositories.change_logs;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
/// Application service for querying the change log (delta tracking).
class QueryChangeLogUseCase { // TODO: UIMUseCase {
  private ChangeLogRepository repo;

  this(ChangeLogRepository repo) {
    this.repo = repo;
  }

  ChangeLogEntry getEntry(TenantId tenantId, ChangeLogEntryId id) {
    return repo.findById(tenantId, id);
  }

  ChangeLogEntry[] query(ChangeLogQueryRequest req) {
    if (!req.objectId.isNull)
      return repo.findByObject(req.tenantId, req.objectId);
    if (req.deltaToken.length > 0)
      return repo.findSinceDeltaToken(req.tenantId, req.deltaToken);
    if (req.sinceTimestamp > 0)
      return repo.findSinceTimestamp(req.tenantId, req.sinceTimestamp);
    if (req.category.length > 0)
      return repo.findByCategory(req.tenantId, toMasterDataCategory(req.category));
    return repo.findByTenant(req.tenantId);
  }

  ChangeLogEntry[] listByTenant(TenantId tenantId) {
    return repo.find(tenantId);
  }

  ChangeLogEntry[] listByObject(TenantId tenantId, MasterDataObjectId objectId) {
    return repo.findByObject(tenantId, objectId);
  }

  ChangeLogEntry[] listSinceDeltaToken(TenantId tenantId, string deltaToken) {
    return repo.findSinceDeltaToken(tenantId, deltaToken);
  }
}
