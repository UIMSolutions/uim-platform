/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.controllers.application;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.identity_authentication.application.usecases.manage.applications;
// import uim.platform.identity_authentication.application.dto;
// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.presentation.http.json_utils;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// HTTP controller for application (service provider) management.
class ApplicationController : SAPController {
  private ManageApplicationsUseCase useCase;

  this(ManageApplicationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/applications", &handleCreate);
    router.get("/api/v1/applications", &handleList);
    router.get("/api/v1/applications/*", &handleGet);
    router.put("/api/v1/applications/*", &handleUpdate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateAppRequest(j.getString("tenantId"), j.getString("name"),
          j.getString("description"), SsoProtocol.oidc, jsonStrArray(j, "redirectUris"),
          jsonStrArray(j, "allowedScopes"), j.getString("samlEntityId"),
          j.getString("samlAcsUrl"));

      auto result = useCase.createApplication(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["applicationId"] = Json(result.applicationId);
        response["clientId"] = Json(result.clientId);
        response["clientSecret"] = Json(result.clientSecret);
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 400);
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
      TenantId tenantId = req.getTenantId;
      auto apps = useCase.listApplications(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = apps.length.toJson;
      response["resources"] = apps.toJson;
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
      auto appId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto app = useCase.getApplication(appId);
      if (app == Application.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Application not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      auto response = toJsonValue(app);
      response.remove("clientSecret"); // Don't expose secret on GET
      res.writeJsonBody(response, 200);
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
      auto appId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto j = req.json;
      auto updateReq = UpdateAppRequest(appId, j.getString("name"),
          jsonStrArray(j, "redirectUris"), jsonStrArray(j, "allowedScopes"));

      auto error = useCase.updateApplication(updateReq);
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
