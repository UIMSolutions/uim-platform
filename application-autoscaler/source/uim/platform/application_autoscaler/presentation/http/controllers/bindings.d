/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class AppBindingController : ManageController {
  private ManageAppBindingsUseCase usecase;

  this(ManageAppBindingsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/bindings", &handleCreate);
    router.get("/api/v1/bindings", &handleList);
    router.get("/api/v1/bindings/*", &handleGet);
    router.delete_("/api/v1/bindings/*", &handleDelete);
    router.post("/api/v1/bindings/*/policy", &handleAttachPolicy);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto bindings = usecase.listBindings(tenantId);
    auto arr = bindings.map!(b => b.toJson()).array.toJson;

    auto response = json.emptyObject
      .set("items", arr)
      .set("totalCount", bindings.length);

    return successResponse("Bindings retrieved successfully", "Retrieved", 200, response);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAppBindingRequest r;
      r.tenantId = data.getString("tenant_id");
      r.appGuid = data.getString("app_guid");
      r.appName = data.getString("app_name");
      r.serviceInstanceId = data.getString("service_instance_id");
      auto result = usecase.createBinding(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Binding created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = AppBindingId(extractIdFromPath(req));

      auto b = usecase.getBinding(tenantId, id);
      if (b.isNull) {
        writeError(res, 404, "Binding not found");
        return;
      }
      res.writeJsonBody(b.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = AppBindingId(extractIdFromPath(req));
      auto result = usecase.deleteBinding(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("message", "Binding deleted"), 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAttachPolicy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto bindingId = AppBindingId(extractIdFromPath(req));
      auto j = req.json;
      auto policyId = data.getString("policy_id");
      auto result = usecase.attachPolicy(tenantId, bindingId, policyId);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("message", "Policy attached"), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
