/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.entities.usage_record;

import uim.platform.usage_data;
mixin(ShowModule!());
@safe:

/// A UsageRecord captures a single raw consumption event for a BTP service or application.
/// These records are the source data from which aggregated reports are derived.
struct UsageRecord {
  mixin TenantEntity!UsageRecordId;

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
  Environment environment;
  SysTime reportedAt;
  string chargebackPeriod; /// YYYY-MM format
  int chargebackYear;
  int chargebackMonth;

  Json toJson() {
    return entityToJson()
      .set("globalAccountId", globalAccountId)
      .set("subaccountId", subaccountId)
      .set("directoryId", directoryId)
      .set("region", region)
      .set("datacenter", datacenter)
      .set("serviceId", serviceId)
      .set("serviceName", serviceName)
      .set("planId", planId)
      .set("planName", planName)
      .set("metricName", metricName)
      .set("metricValue", metricValue)
      .set("environment", environment.to!string)
      .set("reportedAt", reportedAt.toISOExtString())
      .set("chargebackPeriod", chargebackPeriod)
      .set("chargebackYear", chargebackYear)
      .set("chargebackMonth", chargebackMonth);
  }

  static UsageRecord create(string globalAccountId, string subaccountId,
      string serviceId, string serviceName, string metricName, double value,
      Environment env, string region) {
    UsageRecord r;
    r.id = UsageRecordId(randomUUID().toString());
    r.globalAccountId = globalAccountId;
    r.subaccountId = subaccountId;
    r.serviceId = serviceId;
    r.serviceName = serviceName;
    r.metricName = metricName;
    r.metricValue = value;
    r.environment = env;
    r.region = region;
    r.reportedAt = Clock.currTime();
    return r;
  }
}
