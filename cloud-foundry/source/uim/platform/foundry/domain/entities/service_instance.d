/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.service_instance;

import uim.platform.foundry.domain.types;

/// A service instance — a provisioned instance of a marketplace service
/// (e.g. XSUAA, HANA, Destination Service) within a space.
struct ServiceInstance {
  ServiceInstanceId id;
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  string serviceName; // e.g. "xsuaa", "hana", "destination"
  string servicePlanName; // e.g. "lite", "standard", "application"
  ServiceInstanceStatus status = ServiceInstanceStatus.creating;
  string parameters; // JSON string of creation parameters
  string dashboardUrl;
  string tags; // comma-separated tags
  string createdBy;
  long createdAt;
  long updatedAt;
}
