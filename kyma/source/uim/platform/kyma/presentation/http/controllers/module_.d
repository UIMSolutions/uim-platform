/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.module_;




// import uim.platform.kyma.application.usecases.manage.modules;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.kyma_module;
// import uim.platform.kyma.domain.types;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ModuleController : ManageController {
  private ManageModulesUseCase usecase;

  this(ManageModulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/modules", &handleEnable);
    router.get("/api/v1/modules", &handleList);
    router.get("/api/v1/modules/*", &handleGet);
    router.put("/api/v1/modules/*", &handleUpdate);
    router.post("/api/v1/modules/disable/*", &handleDisable);
    router.delete_("/api/v1/modules/*", &handleDelete);
  }

  protected void handleEnable(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      EnableModuleRequest r;
      r.environmentId = data.getString("environmentId");
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.moduleType = data.getString("moduleType");
      r.version_ = data.getString("version");
      r.channel = data.getString("channel");
      r.customResourcePolicy = data.getString("customResourcePolicy");
      r.configurationJson = data.getString("configuration");
      r.enabledBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.enableModule(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto envIdParam = req.params.get("environmentId");
      string envId = envIdParam.length > 0 ? envIdParam : req.headers.get("X-Environment-Id", "");

      auto items = usecase.listByEnvironment(envId);
      auto arr = items.map!(m => m.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto m = usecase.getModule(id);
      if (m.isNull) {
        writeError(res, 404, "Module not found");
        return;
      }
      res.writeJsonBody(m.toJson, 200);
    }
    catch (Exception e) {
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
      UpdateModuleRequest r;
      r.version_ = data.getString("version");
      r.channel = data.getString("channel");
      r.customResourcePolicy = data.getString("customResourcePolicy");
      r.configurationJson = data.getString("configuration");

      auto result = usecase.updateModule(KymaModuleId(id), r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Module updated successfully", "Updated", 200, responseData);
  }

  protected void handleDisable(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.disableModule(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteModule(id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Module deleted successfully", "Deleted", 200, responseData);
  }
}
