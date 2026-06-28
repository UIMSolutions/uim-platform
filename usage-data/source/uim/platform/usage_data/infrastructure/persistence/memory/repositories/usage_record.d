/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.persistence.memory.repositories.usage_record;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// In-memory adapter implementing UsageRecordRepository port.
class MemoryUsageRecordRepository
    : TenantRepository!(UsageRecord, UsageRecordId), UsageRecordRepository {

  UsageRecord[] findByGlobalAccount(TenantId tenantId, string globalAccountId) {
    return find(tenantId).filter!(r => r.globalAccountId == globalAccountId).array;
  }

  UsageRecord[] findBySubaccount(TenantId tenantId, string subaccountId) {
    return find(tenantId).filter!(r => r.subaccountId == subaccountId).array;
  }

  UsageRecord[] findByService(TenantId tenantId, string serviceId) {
    return find(tenantId).filter!(r => r.serviceId == serviceId).array;
  }

  UsageRecord[] findByEnvironment(TenantId tenantId, Environment env) {
    return find(tenantId).filter!(r => r.environment == env).array;
  }

  UsageRecord[] findByChargebackPeriod(TenantId tenantId, string chargebackPeriod) {
    return find(tenantId).filter!(r => r.chargebackPeriod == chargebackPeriod).array;
  }

  size_t countByGlobalAccount(TenantId tenantId, string globalAccountId) {
    return findByGlobalAccount(tenantId, globalAccountId).length;
  }

  void removeByChargebackPeriod(TenantId tenantId, string chargebackPeriod) {
    foreach (r; findByChargebackPeriod(tenantId, chargebackPeriod))
      remove(r);
  }
}
