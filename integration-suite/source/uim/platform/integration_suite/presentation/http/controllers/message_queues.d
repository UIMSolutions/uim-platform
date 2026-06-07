module uim.platform.integration_suite.presentation.http.controllers.message_queues;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

class MessageQueueController : ManageHttpController {
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
      r.tenantId            = tenantId;
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
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Message queue created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.getAll(req.getTenantId);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 500, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.getById(req.getTenantId, precheck.id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Queue retrieved successfully", "OK", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      UpdateQueueRequest r;
      r.tenantId        = tenantId;
      r.id              = precheck.id;
      r.status          = data.getString("status");
      r.maxMessageSize  = data.getInteger("maxMessageSize");
      r.maxQueueSize    = data.getInteger("maxQueueSize");
      r.retentionPeriod = data.getInteger("retentionPeriod");
      r.metadata        = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
     if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Queue updated successfully", "Updated", 200, responseData);}
}
  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.remove(req.getTenantId, precheck.id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Queue deleted successfully", "Deleted", 200, responseData);
  }
}
