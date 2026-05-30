module uim.platform.integration_suite.presentation.http.controllers.topic_subscriptions;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class TopicSubscriptionController : ManageController {
private:
  ManageTopicSubscriptionsUseCase _usecase;

public:
  this(ManageTopicSubscriptionsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/eventmesh/subscriptions",   &handleCreate);
    router.get    ("/api/v1/eventmesh/subscriptions",   &handleList);
    router.get    ("/api/v1/eventmesh/subscriptions/*", &handleGet);
    router.put    ("/api/v1/eventmesh/subscriptions/*", &handleUpdate);
    router.delete_("/api/v1/eventmesh/subscriptions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateSubscriptionRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = precheck.id;
      r.name         = data.getString("name");
      r.queueId      = data.getString("queueId");
      r.topicPattern = data.getString("topicPattern");
      r.protocol     = data.getString("protocol");
      r.endpoint     = data.getString("endpoint");
      r.metadata     = data.jsonStrMap("metadata");
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(result.data, 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto queueId = req.query.get("queueId", "");
      CommandResult result;
      if (queueId.length > 0)
        result = _usecase.listByQueue(req.getTenantId, queueId);
      else
        result = _usecase.getAll(req.getTenantId);
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
      UpdateSubscriptionRequest r;
      r.tenantId     = req.getTenantId;
      r.id           = extractIdFromPath(req);
      r.status       = data.getString("status");
      r.topicPattern = data.getString("topicPattern");
      r.endpoint     = data.getString("endpoint");
      r.metadata     = data.jsonStrMap("metadata");
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
