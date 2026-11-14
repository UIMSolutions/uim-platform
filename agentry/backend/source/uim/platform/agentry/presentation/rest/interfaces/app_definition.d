/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Resolve the caller (XSUAA bearer token or X-Tenant-Id / X-User-Id headers).
/// Authentication itself is enforced by the approuter (xs-app.json).
RequestIdentity identifyCaller(HTTPServerRequest req, HTTPServerResponse res) {
  return resolveIdentity(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
    req.headers.get("X-User-Id", ""), "default");
}

/// vibe.d REST interface for app definitions (registered under <restPath>/app-definitions).
interface IAppDefinitionApi {
  @before!identifyCaller("identity")
  @path("/") @method(HTTPMethod.GET)
  Json[] getAppDefinitions(RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id") @method(HTTPMethod.GET)
  Json getAppDefinition(string _id, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/") @method(HTTPMethod.POST)
  Json createAppDefinition(Json request, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id") @method(HTTPMethod.PUT)
  Json updateAppDefinition(string _id, Json request, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id/publish") @method(HTTPMethod.POST)
  Json publishAppDefinition(string _id, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id") @method(HTTPMethod.DELETE)
  void deleteAppDefinition(string _id, RequestIdentity identity);
}
