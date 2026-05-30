module uim.platform.integration_suite.presentation.http.controllers.message_queues;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MessageQueueController : ManageController {
private:
  ManageMessageQueuesUseCase _usecase;

public:
  this(ManageMessageQueuesUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/eventmesh/queues",   &handleCreate);
    router.get    ("/api/v1/eventmesh/queues",   &handleList);
    router.get    ("/api/v1/eventmesh/queues/*", &handleGet);
    router.put    ("/api/v1/eventmesh/queues/*", &handleUpdate);
    router.delete_("/api/v1/eventmesh/queues/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateQueueRequest r;
      r.tenantId            = req.getTenantId;
      r.id                  = precheck.id;
      r.name                = data.getString("name");
      r.description         = data.getString("description");
      r.maxMessageSize      = data.getInteger("maxMessageSize");
      r.maxQueueSize        = data.getInteger("maxQueueSize");
      r.retentionPeriod     = data.getInteger("retentionPeriod");
      r.deadLetterQueue     = data.getBoolean("deadLetterQueue");
      r.deadLetterQueueName = data.getString("deadLetterQueueName");
      r.metadata            = data.jsonStrMap("metadata");
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(result.data, 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.getAll(req.getTenantId);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 500, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.getById(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto data = precheck.data;
      UpdateQueueRequest r;
      r.tenantId        = req.getTenantId;
      r.id              = extractIdFromPath(req);
      r.status          = data.getString("status");
      r.maxMessageSize  = data.getInteger("maxMessageSize");
      r.maxQueueSize    = data.getInteger("maxQueueSize");
      r.retentionPeriod = data.getInteger("retentionPeriod");
      r.metadata        = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.remove(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
