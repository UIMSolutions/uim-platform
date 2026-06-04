/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.app_configuration;
// import uim.platform.mobile.application.usecases.manage.app_configurations;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class AppConfigurationController : ManageHttpController {
  private ManageAppConfigurationsUseCase usecase;

  this(ManageAppConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/configurations", &handleCreate);
    router.get("/api/v1/configurations", &handleList);
    router.get("/api/v1/configurations/*", &handleGet);
    router.put("/api/v1/configurations/*", &handleUpdate);
    router.delete_("/api/v1/configurations/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = precheck.tenantId;
      CreateAppConfigurationRequest r;
      r.tenantId = precheck.tenantId;
      r.appId = data.getString("appId");
      r.key = data.getString("key");
      r.value = data.getString("value");
      r.description = data.getString("description");
      r.isSecret = data.getBoolean("isSecret");
      r.platform = data.getString("platform");
      r.createdBy = UserId(data.getString("createdBy"));
      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration created successfully");

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
          .set("key", item.key)
          .set("platform", item.platform)
          .set("status", item.status);
      }

      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", results.length)
        .set("message", "App configurations retrieved successfully");

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
          .set("key", result.data.key)
          .set("value", result.data.value)
          .set("description", result.data.description)
          .set("isSecret", result.data.isSecret)
          .set("platform", result.data.platform)
          .set("createdBy", result.data.createdBy)
          .set("message", "App configuration retrieved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateAppConfigurationRequest r;
      r.id = id;
      r.value = data.getString("value");
      r.description = data.getString("description");
      r.isSecret = data.getBoolean("isSecret");
      r.platform = data.getString("platform");
      r.updatedBy = UserId(data.getString("updatedBy"));
      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration updated successfully");

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
      auto id = AppConfigurationId(precheck.id);
      auto result = usecase.deleteAppConfiguration(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
