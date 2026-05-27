/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers
  .deployment;


// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.deployments;
// import uim.platform.data_attribute_recommendation.application.dto;
// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());
@safe:
class DeploymentController : ManageController {
  private ManageDeploymentsUseCase usecase;

  this(ManageDeploymentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/deployments", &handleCreate);
    router.get("/api/v1/deployments", &handleList);
    router.get("/api/v1/deployments/*", &handleGet);
    router.post("/api/v1/deployments/activate/*", &handleActivate);
    router.post("/api/v1/deployments/deactivate/*", &handleDeactivate);
    router.delete_("/api/v1/deployments/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateDeploymentRequest();
      r.tenantId = tenantId;
      r.trainingJobId = data.getString("trainingJobId");
      r.name = data.getString("name");
      r.replicas = j.getInteger("replicas", 1);
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createDeployment(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Deployment created successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = usecase.listDeployments(tenantId);

      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", items.length)
            .set("message", "Deployments retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto dep = usecase.getDeployment(tenantId, id);
      if (dep.isNull) {
        writeError(res, 404, "Deployment not found");
        return;
      }
      res.writeJsonBody(dep.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.activateDeployment(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", Json("active"))
            .set("message", "Deployment activated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.message == "Deployment not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deactivateDeployment(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject  
            .set("id", result.id)
            .set("status", Json("inactive"))
            .set("message", "Deployment deactivated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.message == "Deployment not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deleteDeployment(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("deleted", true)
            .set("message", "Deployment deleted successfully");
            
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDeployment(const ModelDeployment d) {
    return Json.emptyObject
      .set("id", d.id)
      .set("tenantId", d.tenantId)
      .set("trainingJobId", d.trainingJobId)
      .set("modelConfigId", d.modelConfigId)
      .set("name", d.name)
      .set("status", d.status.to!string)
      .set("endpointUrl", d.endpointUrl)
      .set("version", d.version_)
      .set("replicas", d.replicas)
      .set("createdBy", d.createdBy)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);
  }
}
