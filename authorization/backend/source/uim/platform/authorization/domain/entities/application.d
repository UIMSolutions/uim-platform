/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.domain.entities.application;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// An application whose authorizations are managed by the service (AMS
/// "application"). Policies and APIs always belong to exactly one application.
struct ManagedApplication {
  mixin TenantEntity!ManagedApplicationId;

  string name; /// unique per tenant, e.g. "incident-management"
  string organizationId = "global";
  string description;

  void validate() const {
    if (name.strip.length == 0)
      throw AuthorizationException.invalid("Application name is required");
    if (name.length > 128)
      throw AuthorizationException.invalid("Application name exceeds 128 characters");
  }
}
