/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.query_change_log;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.change_log_entry;
import uim.platform.master_data_integration.domain.ports.repositories.change_logs;
import uim.platform.master_data_integration.domain.types;

/// Application service for querying the change log (delta tracking).
class QueryChangeLogUseCase
{
  private ChangeLogRepository repo;

  this(ChangeLogRepository repo)
  {
    this.repo = repo;
  }

  ChangeLogEntry getEntry(ChangeLogEntryId id)
  {
    return repo.findById(id);
  }

  ChangeLogEntry[] query(ChangeLogQueryRequest req)
  {
    if (req.objectId.length > 0)
      return repo.findByObjectId(req.tenantId, req.objectId);
    if (req.deltaToken.length > 0)
      return repo.findSinceDeltaToken(req.tenantId, req.deltaToken);
    if (req.sinceTimestamp > 0)
      return repo.findSinceTimestamp(req.tenantId, req.sinceTimestamp);
    if (req.category.length > 0)
      return repo.findByCategory(req.tenantId, parseCategory(req.category));
    return repo.findByTenant(req.tenantId);
  }

  ChangeLogEntry[] listByTenant(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  ChangeLogEntry[] listByObjectId(TenantId tenantId, MasterDataObjectId objectId)
  {
    return repo.findByObjectId(tenantId, objectId);
  }

  ChangeLogEntry[] listSinceDeltaToken(TenantId tenantId, string deltaToken)
  {
    return repo.findSinceDeltaToken(tenantId, deltaToken);
  }

  private MasterDataCategory parseCategory(string s)
  {
    switch (s)
    {
    case "businessPartner":
      return MasterDataCategory.businessPartner;
    case "costCenter":
      return MasterDataCategory.costCenter;
    case "profitCenter":
      return MasterDataCategory.profitCenter;
    case "companyCode":
      return MasterDataCategory.companyCode;
    case "workforcePerson":
      return MasterDataCategory.workforcePerson;
    case "custom":
      return MasterDataCategory.custom;
    default:
      return MasterDataCategory.businessPartner;
    }
  }
}
