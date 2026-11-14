/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.rest.interfaces.users;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Resolve the caller (bearer token or X-Tenant-Id / X-User-Id headers).
/// Authentication itself is enforced by the approuter (xs-app.json).
RequestIdentity identifyCaller(HTTPServerRequest req, HTTPServerResponse res) {
  return resolveIdentity(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
    req.headers.get("X-User-Id", ""), "default");
}

/// vibe.d REST interface for users (registered under <restPath>/users).
interface IUserApi {
  @before!identifyCaller("identity")
  @path("/") @method(HTTPMethod.GET)
  Json[] getUsers(RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id") @method(HTTPMethod.GET)
  Json getUser(string _id, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/") @method(HTTPMethod.POST)
  Json createUser(Json request, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id") @method(HTTPMethod.PUT)
  Json updateUser(string _id, Json request, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id/lock") @method(HTTPMethod.POST)
  Json lockUser(string _id, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id/unlock") @method(HTTPMethod.POST)
  Json unlockUser(string _id, RequestIdentity identity);

  @before!identifyCaller("identity")
  @path("/:id") @method(HTTPMethod.DELETE)
  void deleteUser(string _id, RequestIdentity identity);
}
