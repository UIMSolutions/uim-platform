/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.dto.usage_record;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:

struct CreateUsageRecordRequest {
  string globalAccountId;
  string subaccountId;
  string directoryId;
  string region;
  string datacenter;
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  double metricValue;
  string environment;
  string chargebackPeriod;
}

struct UsageRecordResponse {
  UsageRecordId recordId;
  TenantId tenantId;
  string globalAccountId;
  string subaccountId;
  string directoryId;
  string region;
  string datacenter;
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  double metricValue;
  string environment;
  long reportedAt;
  string chargebackPeriod;

  bool isEmpty() const { return recordId.value.length == 0; }

  static UsageRecordResponse fromEntity(UsageRecord r) {
    if (r.isNull) return UsageRecordResponse.init;
    return UsageRecordResponse(r.id, r.tenantId, r.globalAccountId,
      r.subaccountId, r.directoryId, r.region, r.datacenter, r.serviceId,
      r.serviceName, r.planId, r.planName, r.metricName, r.metricValue,
      r.environment.to!string, r.reportedAt.toISOExtString(), r.chargebackPeriod);
  }
}
