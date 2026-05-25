/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.data_flow;
// import uim.platform.datasphere.application.usecases.manage.data_flows;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class DataFlowController : ManageController {
  private ManageDataFlowsUseCase usecase;

  this(ManageDataFlowsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/dataFlows", &handleList);
    router.get("/api/v1/datasphere/dataFlows/*", &handleGet);
    router.post("/api/v1/datasphere/dataFlows", &handleCreate);
    router.delete_("/api/v1/datasphere/dataFlows/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      
      CreateDataFlowRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.scheduleExpression = j.getString("scheduleExpression");
      r.scheduleFrequency = j.getString("scheduleFrequency");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Data flow created");
          
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto flows = usecase.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (df; flows) {
        jarr ~= Json.emptyObject
          .set("id", df.id)
          .set("name", df.name)
          .set("description", df.description)
          .set("lastRunAt", df.lastRunAt)
          .set("lastRunDurationMs", df.lastRunDurationMs)
          .set("createdAt", df.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", flows.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataFlowId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto df = usecase.getDataFlow(tenantId, spaceId, id);
      if (df.isNull) {
        writeError(res, 404, "Data flow not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", df.id)
        .set("name", df.name)
        .set("description", df.description)
        .set("scheduleExpression", df.scheduleExpression)
        .set("lastRunAt", df.lastRunAt)
        .set("lastRunDurationMs", df.lastRunDurationMs)
        .set("lastRunMessage", df.lastRunMessage)
        .set("createdAt", df.createdAt)
        .set("updatedAt", df.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataFlowId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = usecase.deleteDataFlow(tenantId, spaceId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
