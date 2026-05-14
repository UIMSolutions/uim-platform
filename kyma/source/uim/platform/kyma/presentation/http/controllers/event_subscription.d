/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.event_subscription;






// import uim.platform.kyma.application.usecases.manage.event_subscriptions;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.event_subscription;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class EventSubscriptionController : PlatformController {
  private ManageEventSubscriptionsUseCase usecase;

  this(ManageEventSubscriptionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/event-subscriptions", &handleCreate);
    router.get("/api/v1/event-subscriptions", &handleList);
    router.get("/api/v1/event-subscriptions/*", &handleGet);
    router.put("/api/v1/event-subscriptions/*", &handleUpdate);
    router.delete_("/api/v1/event-subscriptions/*", &handleDelete);
    router.post("/api/v1/event-subscriptions/pause/*", &handlePause);
    router.post("/api/v1/event-subscriptions/resume/*", &handleResume);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateEventSubscriptionRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.source = j.getString("source");
      r.eventTypes = getStrings(j, "eventTypes");
      r.typeEncoding = j.getString("typeEncoding");
      r.sinkUrl = j.getString("sinkUrl");
      r.sinkServiceName = j.getString("sinkServiceName");
      r.sinkServicePort = j.getInteger("sinkServicePort");
      r.maxInFlightMessages = j.getInteger("maxInFlightMessages");
      r.exactTypeMatching = j.getBoolean("exactTypeMatching", true);
      r.filterAttributes = jsonStrMap(j, "filterAttributes");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");
      auto source = req.params.get("source");

      EventSubscription[] items;
      if (!source.isEmpty)
        items = usecase.listBySource(source);
      else if (!nsId.isEmpty)
        items = usecase.listByNamespace(nsId);
      else if (!envId.isEmpty)
        items = usecase.listByEnvironment(envId);

      auto arr = items.map!(sub => sub.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length);
          
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto sub = usecase.getSubscription(tenantId, id);
      if (sub.isNull) {
        writeError(res, 404, "Subscription not found");
        return;
      }
      res.writeJsonBody(sub.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateEventSubscriptionRequest r;
      r.description = j.getString("description");
      r.eventTypes = getStrings(j, "eventTypes");
      r.sinkUrl = j.getString("sinkUrl");
      r.sinkServiceName = j.getString("sinkServiceName");
      r.sinkServicePort = j.getInteger("sinkServicePort");
      r.maxInFlightMessages = j.getInteger("maxInFlightMessages");
      r.exactTypeMatching = j.getBoolean("exactTypeMatching", true);
      r.filterAttributes = jsonStrMap(j, "filterAttributes");
      r.labels = jsonStrMap(j, "labels");

      auto result = usecase.updateSubscription(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.pauseSubscription(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.resumeSubscription(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteSubscription(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
