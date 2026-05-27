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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateLogStreamRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.sourceType = data.getString("sourceType");
      r.retentionPolicyId = data.getString("retentionPolicyId");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = usecase.createStream(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
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

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = LogStreamprecheck.id);
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
      auto tenantId = precheck.tenantId;
      auto id = LogStreamprecheck.id);
      auto data = precheck.data;
      UpdateLogStreamRequest r;
      r.tenantId = tenantId;
      r.streamId = id;
      r.description = data.getString("description");
      r.retentionPolicyId = data.getString("retentionPolicyId");
      r.isActive = data.getBoolean("isActive", true);

      auto result = usecase.updateStream(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
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
      auto tenantId = precheck.tenantId;
      auto streamId = LogStreamprecheck.id);
      usecase.deleteStream(tenantId, streamId);

      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
