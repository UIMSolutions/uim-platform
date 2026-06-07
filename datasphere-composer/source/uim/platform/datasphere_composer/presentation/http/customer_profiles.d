/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.customer_profiles;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;


// mixin(ShowModule!());

@safe:
class CustomerProfileController : ManageHttpController {
  private ManageCustomerProfilesUseCase usecase;

  this(ManageCustomerProfilesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/profiles",         &handleList);
    router.get("/api/v1/composer/profiles/*",        &handleGet);
    router.post("/api/v1/composer/profiles/search",  &handleSearch);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Profile not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleSearch(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    auto tenantId = precheck.tenantId;
    auto email = data.getString("email");
    auto externalId = data.getString("externalId");

    CustomerProfile[] items;
    if (email.length > 0) {
      items = usecase.searchByEmail(tenantId, email);
    } else if (externalId.length > 0) {
      items = usecase.searchByExternalId(tenantId, externalId);
    } else {
      items = usecase.list(tenantId);
    }

    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }
}
