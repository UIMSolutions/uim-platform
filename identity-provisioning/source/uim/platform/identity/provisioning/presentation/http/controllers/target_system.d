/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.target_system;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;


// import uim.platform.identity.provisioning.application.usecases.manage.target_systems;
// import uim.platform.identity.provisioning.application.dto;
// import uim.platform.identity.provisioning.domain.entities.target_system;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class TargetSystemController : PlatformController {
  private ManageTargetSystemsUseCase usecase;

  this(ManageTargetSystemsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/target-systems", &handleCreate);
    router.get("/api/v1/target-systems", &handleList);
    router.get("/api/v1/target-systems/*", &handleGetById);
    router.put("/api/v1/target-systems/*", &handleUpdate);
    router.delete_("/api/v1/target-systems/*", &handleDelete);
    router.post("/api/v1/target-systems/activate/*", &handleActivate);
    router.post("/api/v1/target-systems/deactivate/*", &handleDeactivate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateTargetSystemRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.systemType = parseSystemType(j.getString("systemType"));
      r.connectionConfig = j.getString("connectionConfig");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createTargetSystem(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;

      auto items = usecase.listTargetSystems(tenantId);
      auto arr = items.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto sys = usecase.getTargetSystem(tenantId, id);
      if (sys.isNull) {
        writeError(res, 404, "Target system not found");
        return;
      }
      res.writeJsonBody(sys.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateTargetSystemRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.connectionConfig = j.getString("connectionConfig");

      auto result = usecase.updateTargetSystem(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Target system not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = usecase.activateSystem(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "active");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Target system not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = usecase.deactivateSystem(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "inactive");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = usecase.deleteTargetSystem(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
