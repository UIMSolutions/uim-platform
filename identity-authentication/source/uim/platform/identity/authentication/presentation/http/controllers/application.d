/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.controllers.application;




// import uim.platform.identity.authentication.application.usecases.manage.applications;
// import uim.platform.identity.authentication.application.dto;
// import uim.platform.identity.authentication.domain.entities.application;
// import uim.platform.identity.authentication.domain.types;
import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// HTTP controller for application (service provider) management.
class ApplicationController : PlatformController {
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

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateAppRequest request;
      request.tenantId = tenantId;
      request.name = j.getString("name");
      request.description = j.getString("description");
      request.protocol = SsoProtocol.oidc;
      request.redirectUris = getStrings(j, "redirectUris");
      request.allowedScopes = getStrings(j, "allowedScopes");
      request.samlEntityId = j.getString("samlEntityId");
      request.samlAcsUrl = j.getString("samlAcsUrl");

      auto result = useCase.createApplication(request);

      if (result.isSuccess()) {
        auto response = Json.emptyObject;
        response["applicationId"] = Json(result.applicationId);
        response["clientId"] = Json(result.clientId);
        response["clientSecret"] = Json(result.clientSecret);
        res.writeJsonBody(response, 201);
      } else {
        auto response = Json.emptyObject;
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 400);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto apps = useCase.listApplications(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = apps.length.toJson;
      response["resources"] = apps.toJson;
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;
      auto tenantId = req.getTenantId;
      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto appId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto app = useCase.getApplication(tenantId, appId);
      if (app == Application.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Application not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      auto response = toJsonValue(app);
      response.remove("clientSecret"); // Don't expose secret on GET
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;

      auto tenantId = req.getTenantId;
      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto appId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto j = req.json;
      UpdateAppRequest request;
      request.tenantId = tenantId;
      request.applicationId = appId;
      request.name = j.getString("name");
      request.redirectUris = getStrings(j, "redirectUris");
      request.allowedScopes = getStrings(j, "allowedScopes");

      auto error = useCase.updateApplication(request);
      if (error.length > 0) {
        auto errRes = Json.emptyObject
          .set("error", error);

        res.writeJsonBody(errRes, 404);
      } else {
        auto resp = Json.emptyObject
          .set("status", "updated");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject
        .set("error", "Internal server error");

      res.writeJsonBody(errRes, 500);
    }
  }
}
