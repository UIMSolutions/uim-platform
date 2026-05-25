/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.stream;
// import uim.platform.logging.application.usecases.manage.log_streams;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.log_stream;
// import uim.platform.logging.domain.types;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class StreamController : ManageController {
  private ManageLogStreamsUseCase usecase;

  this(ManageLogStreamsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/streams", &handleCreate);
    router.get("/api/v1/streams", &handleList);
    router.get("/api/v1/streams/*", &handleGet);
    router.put("/api/v1/streams/*", &handleUpdate);
    router.delete_("/api/v1/streams/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateLogStreamRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.sourceType = j.getString("sourceType");
      r.retentionPolicyId = j.getString("retentionPolicyId");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = usecase.createStream(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Log stream created");

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
      auto streams = usecase.listStreams(tenantId);

      auto jarr = Json.emptyArray;
      foreach (s; streams) {
        jarr ~= Json.emptyObject
          .set("id", s.id)
          .set("name", s.name)
          .set("description", s.description)
          .set("isActive", s.isActive);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", streams.length)
        .set("message", "Log stream list retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = LogStreamId(extractIdFromPath(req.requestURI.to!string));
      auto s = usecase.getStream(tenantId, id);

      if (s.isNull) {
        writeError(res, 404, "Log stream not found");
        return;
      }

      auto response = Json.emptyObject
        .set("id", s.id)
        .set("tenantId", s.tenantId)
        .set("name", s.name)
        .set("description", s.description)
        .set("isActive", s.isActive)
        .set("retentionPolicyId", s.retentionPolicyId);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = LogStreamId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateLogStreamRequest r;
      r.tenantId = tenantId;
      r.streamId = id;
      r.description = j.getString("description");
      r.retentionPolicyId = j.getString("retentionPolicyId");
      r.isActive = j.getBoolean("isActive", true);

      auto result = usecase.updateStream(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Log stream updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto streamId = LogStreamId(extractIdFromPath(req.requestURI.to!string));
      usecase.deleteStream(tenantId, streamId);

      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
