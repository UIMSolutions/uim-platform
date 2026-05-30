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
class ApplicationController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateAppRequest request;
      request.tenantId = tenantId;
      request.name = data.getString("name");
      request.description = data.getString("description");
      request.protocol = SsoProtocol.oidc;
      request.redirectUris = data.getStrings("redirectUris");
      request.allowedScopes = data.getStrings("allowedScopes");
      request.samlEntityId = data.getString("samlEntityId");
      request.samlAcsUrl = data.getString("samlAcsUrl");

      auto result = useCase.createApplication(request);

      if (result.isSuccess()) {
        auto response = Json.emptyObject;
        response["applicationId"] = Json(result.applicationId);
        response["clientId"] = Json(result.clientId);
        response["clientSecret"] = Json(result.clientSecret);
        res.writeJsonBody(response, 201);
      } else {
        auto response = Json.emptyObject;
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 400);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;
      auto tenantId = precheck.tenantId;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // import std.string : lastIndexOf;

      auto tenantId = precheck.tenantId;
      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto appId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto data = precheck.data;
      UpdateAppRequest request;
      request.tenantId = tenantId;
      request.applicationId = appId;
      request.name = data.getString("name");
      request.redirectUris = data.getStrings("redirectUris");
      request.allowedScopes = data.getStrings("allowedScopes");

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
