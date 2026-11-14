/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.domain.entities.application_api;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// An API of an application (endpoint + operations) that policies protect.
struct ApplicationApi {
  mixin TenantEntity!ApplicationApiId;

  ManagedApplicationId applicationId;
  string name; /// unique per application
  string endpoint; /// e.g. "/odata/v4/incidents"
  string[] operations; /// e.g. ["Read", "Create", "Update"]

  void validate() const {
    if (applicationId.isNull)
      throw AuthorizationException.invalid("applicationId is required");
    if (name.strip.length == 0)
      throw AuthorizationException.invalid("API name is required");
    if (endpoint.strip.length == 0)
      throw AuthorizationException.invalid("API endpoint is required");
  }
}
