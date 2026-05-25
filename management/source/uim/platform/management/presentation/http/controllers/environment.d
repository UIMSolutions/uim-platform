/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.environment;


// 
// import uim.platform.management.application.usecases.manage.environment_instances;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.environment_instance;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EnvironmentController : ManageController {
  private ManageEnvironmentInstancesUseCase usecase;

  this(ManageEnvironmentInstancesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/environments", &handleCreate);
    router.get("/api/v1/environments", &handleList);
    router.get("/api/v1/environments/*", &handleGet);
    router.put("/api/v1/environments/*", &handleUpdate);
    router.post("/api/v1/environments/deprovision/*", &handleDeprovision);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateEnvironmentInstanceRequest r;
      r.tenantId = tenantId;
      r.subaccountId = j.getString("subaccountId");
      r.globalAccountId = j.getString("globalAccountId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.environmentType = j.getString("environmentType");
      r.planName = j.getString("planName");
      r.landscapeLabel = j.getString("landscapeLabel");
      r.memoryQuotaMb = j.getInteger("memoryQuotaMb");
      r.routeQuota = j.getInteger("routeQuota");
      r.serviceQuota = j.getInteger("serviceQuota");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));
      r.parameters = jsonStrMap(j, "parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = usecase.createEnvironmentInstance(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Environment instance created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto subId = req.params.get("subaccountId");
      auto envType = req.params.get("environmentType");

      EnvironmentInstance[] items;
      if (envType.length > 0 && !subId.isEmpty)
        items = usecase.listEnvironmentInstances(tenantId, subId, envType);
      else if (!subId.isEmpty)
        items = usecase.listEnvironmentInstances(tenantId, subId);

      auto arr = items.map!(inst => inst.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Environment instances retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = EnvironmentInstanceId(extractId(req.requestURI));
      auto inst = usecase.getEnvironmentInstance(tenantId, id);
      if (inst.isNull) {
        writeError(res, 404, "Environment instance not found");
        return;
      }
      res.writeJsonBody(inst.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = EnvironmentInstanceId(extractId(req.requestURI));
      auto j = req.json;
      UpdateEnvironmentInstanceRequest request;
      request.tenantId = tenantId;
      request.environmentInstanceId = id;
      request.description = j.getString("description");
      request.memoryQuotaMb = j.getInteger("memoryQuotaMb");
      request.routeQuota = j.getInteger("routeQuota");
      request.serviceQuota = j.getInteger("serviceQuota");
      request.parameters = jsonStrMap(j, "parameters");
      request.labels = jsonStrMap(j, "labels");

      auto result = usecase.updateEnvironmentInstance(request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGetDeprovision(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = EnvironmentInstanceId(extractId(req.requestURI));
      auto result = usecase.deprovisionEnvironmentInstance(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
