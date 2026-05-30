/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.user_session;
// import uim.platform.mobile.application.usecases.manage.user_sessions;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile.presentation.http
// import uim.platform.mobile;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class UserSessionController : ManageController {
  private ManageUserSessionsUseCase usecase;

  this(ManageUserSessionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/sessions", &handleCreate);
    router.get("/api/v1/sessions", &handleList);
    router.get("/api/v1/sessions/*", &handleGet);
    router.post("/api/v1/sessions/*/terminate", &handleTerminate);
    router.delete_("/api/v1/sessions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateUserSessionRequest r;
      r.tenantId = tenantId;
      r.appId = data.getString("appId");
      r.deviceId = data.getString("deviceId");
      r.userId = data.getString("userId");
      r.ipAddress = data.getString("ipAddress");
      r.userAgent = data.getString("userAgent");
      r.platform = data.getString("platform");
      r.appVersion = data.getString("appVersion");
      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
        .set("id", item.id)
        .set("appId", item.appId)
        .set("userId", item.userId)
        .set("platform", item.platform)
        .set("status", item.status);
      }

      auto resp = Json.emptyObject
        .set("items", items);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.get(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("appId", result.data.appId)
          .set("deviceId", result.data.deviceId)
          .set("userId", result.data.userId)
          .set("ipAddress", result.data.ipAddress)
          .set("userAgent", result.data.userAgent)
          .set("platform", result.data.platform)
          .set("appVersion", result.data.appVersion)
          .set("status", result.data.status);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleTerminate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.terminate(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = UserSessionId(precheck.id);
      auto result = usecase.delete(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeBody("", 204);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
