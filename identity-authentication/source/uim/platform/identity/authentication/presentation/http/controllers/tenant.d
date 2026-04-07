/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.controllers.tenant;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.identity_authentication.application.usecases.manage.tenants;
// import uim.platform.identity_authentication.application.dto;
// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.presentation.http.json_utils;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// HTTP controller for tenant management.
class TenantController : SAPController {
  private ManageTenantsUseCase useCase;

  this(ManageTenantsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/tenants", &handleCreate);
    router.get("/api/v1/tenants", &handleList);
    router.get("/api/v1/tenants/*", &handleGet);
    router.put("/api/v1/tenants/*", &handleUpdate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateTenantRequest(j.getString("name"),
          j.getString("subdomain"), SsoProtocol.oidc, [AuthMethod.form], false);

      auto result = useCase.createTenant(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["tenantId"] = Json(result.tenantId);
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 409);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenants = useCase.listTenants();
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long) tenants.length);
      response["resources"] = toJsonArray(tenants);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto tenant = useCase.getTenant(tenantId);
      if (tenant == Tenant.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Tenant not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      res.writeJsonBody(toJsonValue(tenant), 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto j = req.json;
      auto updateReq = UpdateTenantRequest(tenantId, j.getString("name"), []);

      auto error = useCase.updateTenant(updateReq);
      if (error.length > 0) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 404);
      }
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}
