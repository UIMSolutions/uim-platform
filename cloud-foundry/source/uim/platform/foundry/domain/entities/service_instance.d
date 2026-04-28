/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.service_instance;

// import uim.platform.foundry.domain.types;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// A service instance — a provisioned instance of a marketplace service
/// (e.g. XSUAA, HANA, Destination Service) within a space.
struct ServiceInstance {
  mixin TenantEntity!ServiceInstanceId;

  SpaceId spaceId;
  string name;
  string serviceName; // e.g. "xsuaa", "hana", "destination"
  string servicePlanName; // e.g. "lite", "standard", "application"
  ServiceInstanceStatus status = ServiceInstanceStatus.creating;
  string parameters; // JSON string of creation parameters
  string dashboardUrl;
  string tags; // comma-separated tags

  Json toJson() {
    return entityToJson()
      .set("spaceId", si.spaceId)
      .set("name", si.name)
      .set("serviceName", si.serviceName)
      .set("servicePlanName", si.servicePlanName)
      .set("status", si.status.to!string)
      .set("parameters", si.parameters)
      .set("dashboardUrl", si.dashboardUrl)
      .set("tags", si.tags);
  }
}
