/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.usecases.usage_records;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// Application service: usage record use cases.
class UsageRecordUseCases {
  private UsageRecordRepository repo;

  this(UsageRecordRepository repo) {
    this.repo = repo;
  }

  UsageRecordResponse submitRecord(CreateUsageRecordRequest req) {
    Environment env;
    try { env = req.environment.to!Environment; } catch (Exception) { env = Environment.other; }
    auto record = UsageRecord.create(req.accountId, req.subaccountId,
      req.serviceId, req.serviceName, req.metricName, req.metricValue, env, req.region);
    record.directoryId = req.directoryId;
    record.datacenter = req.datacenter;
    record.planId = req.planId;
    record.planName = req.planName;
    record.chargebackPeriod = req.chargebackPeriod;
    repo.save(record);
    return UsageRecordResponse.fromEntity(record);
  }

  UsageRecordResponse getRecord(TenantId tenantId, UsageRecordId id) {
    auto r = repo.findById(tenantId, id);
    return UsageRecordResponse.fromEntity(r);
  }

  UsageRecordResponse[] listRecords(TenantId tenantId) {
    UsageRecordResponse[] result;
    foreach (r; repo.find(tenantId))
      result ~= UsageRecordResponse.fromEntity(r);
    return result;
  }

  UsageRecordResponse[] listByGlobalAccount(TenantId tenantId, string globalAccountId) {
    UsageRecordResponse[] result;
    foreach (r; repo.findByGlobalAccount(tenantId, globalAccountId))
      result ~= UsageRecordResponse.fromEntity(r);
    return result;
  }

  UsageRecordResponse[] listBySubaccount(TenantId tenantId, string subaccountId) {
    UsageRecordResponse[] result;
    foreach (r; repo.findBySubaccount(tenantId, subaccountId))
      result ~= UsageRecordResponse.fromEntity(r);
    return result;
  }

  CommandResult deleteRecord(TenantId tenantId, UsageRecordId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull) return CommandResult(false, "", "Usage record not found");
    repo.remove(r);
    return CommandResult(true, r.id.value, "");
  }
}
