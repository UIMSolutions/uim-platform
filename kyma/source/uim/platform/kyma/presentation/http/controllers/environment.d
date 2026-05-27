/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.environment;




// import uim.platform.kyma.application.usecases.manage.environments;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.kyma_environment;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class EnvironmentController : ManageController {
  private ManageEnvironmentsUseCase usecase;

  this(ManageEnvironmentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/environments", &handleCreate);
    router.get("/api/v1/environments", &handleList);
    router.get("/api/v1/environments/*", &handleGet);
    router.put("/api/v1/environments/*", &handleUpdate);
    router.delete_("/api/v1/environments/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateEnvironmentRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.plan = data.getString("plan");
      r.region = data.getString("region");
      r.machineCount = j.getInteger("machineCount");
      r.machineType = data.getString("machineType");
      r.autoScalerMin = j.getInteger("autoScalerMin");
      r.autoScalerMax = j.getInteger("autoScalerMax");
      r.oidcIssuerUrl = data.getString("oidcIssuerUrl");
      r.oidcClientId = data.getString("oidcClientId");
      r.oidcGroupsClaim = getStrings(j, "oidcGroupsClaim");
      r.oidcUsernameClaim = getStrings(j, "oidcUsernameClaim");
      r.administrators = getStrings(j, "administrators");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));

      KymaEnvironment[] envs = subaccountId.isEmpty ?
        usecase.listByTenant(tenantId) :
        usecase.listBySubaccount(tenantId, subaccountId);

      auto arr = envs.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", envs.length);
          
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = KymaEnvironmentId(precheck.id);
      if (!usecase.hasEnvironment(tenantId, id)) {
        writeError(res, 404, "Environment not found");
        return;
      }

      auto env = usecase.getEnvironment(tenantId, id);
      res.writeJsonBody(env.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = KymaEnvironmentId(precheck.id);
      auto data = precheck.data;
      UpdateEnvironmentRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.machineCount = j.getInteger("machineCount");
      r.machineType = data.getString("machineType");
      r.autoScalerMin = j.getInteger("autoScalerMin");
      r.autoScalerMax = j.getInteger("autoScalerMax");
      r.oidcIssuerUrl = data.getString("oidcIssuerUrl");
      r.oidcClientId = data.getString("oidcClientId");
      r.administrators = getStrings(j, "administrators");

      auto result = usecase.updateEnvironment(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = KymaEnvironmentId(precheck.id);
      auto result = usecase.deleteEnvironment(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
