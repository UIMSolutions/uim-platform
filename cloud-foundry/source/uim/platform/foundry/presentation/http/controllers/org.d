/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.org;






// import uim.platform.foundry.application.usecases.manage.orgs;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.organization;
import uim.platform.foundry;

class OrgController : ManageController {
  private ManageOrgsUseCase useCase;

  this(ManageOrgsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/orgs", &handleCreate);
    router.get("/api/v1/orgs", &handleList);
    router.post("/api/v1/orgs/suspend/*", &handleSuspend);
    router.post("/api/v1/orgs/activate/*", &handleActivate);
    router.get("/api/v1/orgs/*", &handleGet);
    router.put("/api/v1/orgs/*", &handleUpdate);
    router.delete_("/api/v1/orgs/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateOrgRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.memoryQuotaMb = j.getInteger("memoryQuotaMb", 0);
      r.instanceMemoryLimitMb = j.getInteger("instanceMemoryLimitMb", 0);
      r.totalRoutes = j.getInteger("totalRoutes", 0);
      r.totalServices = j.getInteger("totalServices", 0);
      r.totalAppInstances = j.getInteger("totalAppInstances", 0);
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = useCase.createOrg(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Organization created");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

    auto orgs = useCase.listOrgs(tenantId);

      auto arr = orgs.map!(o => o.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", orgs.length)
        .set("message", "Organizations retrieved");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = OrgId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto org = useCase.getOrg(tenantId, id);
      if (org.isNull) {
        writeError(res, 404, "Organization not found");
        return;
      }
      res.writeJsonBody(org.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = OrgId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateOrgRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.memoryQuotaMb = j.getInteger("memoryQuotaMb", 0);
      r.instanceMemoryLimitMb = j.getInteger("instanceMemoryLimitMb", 0);
      r.totalRoutes = j.getInteger("totalRoutes", 0);
      r.totalServices = j.getInteger("totalServices", 0);
      r.totalAppInstances = j.getInteger("totalAppInstances", 0);

      auto result = useCase.updateOrg(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Organization updated");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = OrgId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.suspendOrg(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Organization suspended");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = OrgId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.activateOrg(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Organization activated");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = OrgId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteOrg(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Organization deleted");
          
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
