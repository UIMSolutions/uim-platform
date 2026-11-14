/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.presentation.rest.interfaces;

import vibe.web.rest;
import vibe.http.common : HTTPMethod;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Runtime API for applications (tenant from X-Tenant-Id, token from Authorization).
///
///   POST /rest/v1/authorization/check                   {principalId, application, resource, action, groups?, attributes?}
///   GET  /rest/v1/authorization/principals/:principal/policies?application=&groups=
///   GET  /rest/v1/authorization/statistics
interface IAuthorizationRuntimeApi {
  @path("/check") @method(HTTPMethod.POST)
  @headerParam("tenantId", "X-Tenant-Id") @headerParam("authorization", "Authorization")
  Json check(string principalId, string application, string resource, string action, string[] groups = null,
    string[string] attributes = null, string tenantId = "", string authorization = "");

  @path("/principals/:principal/policies") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-Id") @headerParam("authorization", "Authorization")
  @queryParam("application", "application") @queryParam("groups", "groups")
  Json principalPolicies(string _principal, string application = "", string groups = "", string tenantId = "",
    string authorization = "");

  @path("/statistics") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-Id") @headerParam("authorization", "Authorization")
  Json statistics(string tenantId = "", string authorization = "");
}
