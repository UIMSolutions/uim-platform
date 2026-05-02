/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.monitored_resource;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// A monitored application, database system, or service on SAP BTP.
struct MonitoredResource {
  mixin TenantEntity!(MonitoredResourceId);
  
  SubaccountId subaccountId;
  string name;
  string description;
  ResourceType resourceType = ResourceType.javaApplication;
  ResourceState state = ResourceState.unknown;
  string url;
  string runtime;
  string region;
  int instanceCount;
  string[] tags;
  string registeredBy;
  long registeredAt;
  long lastSeenAt;

  Json toJson() const {
    return entityToJson
      .set("subaccountId", subaccountId)
      .set("name", name)
      .set("description", description)
      .set("resourceType", resourceType.to!string)
      .set("state", state.to!string)
      .set("url", url)
      .set("runtime", runtime)
      .set("region", region)
      .set("instanceCount", instanceCount)
      .set("tags", tags)
      .set("registeredBy", registeredBy)
      .set("registeredAt", registeredAt)
      .set("lastSeenAt", lastSeenAt);
  }
}
