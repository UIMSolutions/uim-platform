/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.service_instance;

import uim.platform.html_repository.domain.types;

struct ServiceInstance {
  mixin TenantEntity!(ServiceInstanceId);

  SpaceId spaceId;
  string name;
  string description;
  ServicePlan plan;
  InstanceStatus status;
  long sizeQuotaMb; // max storage in MB (default 100)
  long usedSizeBytes; // current usage
  int appCount; // number of apps hosted

  Json toJson() const {
    auto j = entityToJson
      .set("spaceId", spaceId.value)
      .set("name", name)
      .set("description", description)
      .set("plan", plan.toString())
      .set("status", status.toString())
      .set("sizeQuotaMb", sizeQuotaMb)
      .set("usedSizeBytes", usedSizeBytes)
      .set("appCount", appCount);

    return j;
  }
}
