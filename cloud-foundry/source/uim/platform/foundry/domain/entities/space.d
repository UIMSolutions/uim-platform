/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.space;

import uim.platform.foundry.domain.types;

/// A space — an isolated area within an organization where applications,
/// services, and routes are deployed and managed.
struct Space {
  SpaceId id;
  OrgId orgId;
  TenantId tenantId;
  string name;
  SpaceStatus status = SpaceStatus.active;
  bool allowSsh = true;
  string createdBy;
  long createdAt;
  long updatedAt;
}
