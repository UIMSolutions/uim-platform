/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.monitored_resource;

import uim.platform.monitoring.domain.types;

/// A monitored application, database system, or service on SAP BTP.
struct MonitoredResource {
  MonitoredResourceId id;
  TenantId tenantId;
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
}
