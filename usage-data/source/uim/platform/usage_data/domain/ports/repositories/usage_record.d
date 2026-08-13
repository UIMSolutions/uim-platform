/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.ports.repositories.usage_record;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:
/// Port: outgoing repository interface for UsageRecord persistence.
interface IUsageRecordRepository : ITenantRepository!(UsageRecord, UsageRecordId) {

  UsageRecord[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  UsageRecord[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  UsageRecord[] findByService(TenantId tenantId, string serviceId);
  UsageRecord[] findByEnvironment(TenantId tenantId, Environment env);
  UsageRecord[] findByChargebackPeriod(TenantId tenantId, string chargebackPeriod);
  size_t countByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  void removeByChargebackPeriod(TenantId tenantId, string chargebackPeriod);
}
