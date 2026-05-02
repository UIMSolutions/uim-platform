/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.event_subscription;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.event_subscriptions;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.event_subscription;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class EventSubscriptionController : PlatformController {
  private ManageEventSubscriptionsUseCase uc;

  this(ManageEventSubscriptionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/event-subscriptions", &handleCreate);
    router.get("/api/v1/event-subscriptions", &handleList);
    router.get("/api/v1/event-subscriptions/*", &handleGetById);
    router.put("/api/v1/event-subscriptions/*", &handleUpdate);
    router.delete_("/api/v1/event-subscriptions/*", &handleDelete);
    router.post("/api/v1/event-subscriptions/pause/*", &handlePause);
    router.post("/api/v1/event-subscriptions/resume/*", &handleResume);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateEventSubscriptionRequest r;
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.source = j.getString("source");
      r.eventTypes = getStringArray(j, "eventTypes");
      r.typeEncoding = j.getString("typeEncoding");
      r.sinkUrl = j.getString("sinkUrl");
      r.sinkServiceName = j.getString("sinkServiceName");
      r.sinkServicePort = j.getInteger("sinkServicePort");
      r.maxInFlightMessages = j.getInteger("maxInFlightMessages");
      r.exactTypeMatching = j.getBoolean("exactTypeMatching", true);
      r.filterAttributes = jsonStrMap(j, "filterAttributes");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");
      auto source = req.params.get("source");

      EventSubscription[] items;
      if (source.length > 0)
        items = uc.listBySource(source);
      else if (nsId.length > 0)
        items = uc.listByNamespace(nsId);
      else if (envId.length > 0)
        items = uc.listByEnvironment(envId);
      else
        items = [];

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

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto sub = uc.getSubscription(id);
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

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateEventSubscriptionRequest r;
      r.description = j.getString("description");
      r.eventTypes = getStringArray(j, "eventTypes");
      r.sinkUrl = j.getString("sinkUrl");
      r.sinkServiceName = j.getString("sinkServiceName");
      r.sinkServicePort = j.getInteger("sinkServicePort");
      r.maxInFlightMessages = j.getInteger("maxInFlightMessages");
      r.exactTypeMatching = j.getBoolean("exactTypeMatching", true);
      r.filterAttributes = jsonStrMap(j, "filterAttributes");
      r.labels = jsonStrMap(j, "labels");

      auto result = uc.updateSubscription(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.pauseSubscription(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.resumeSubscription(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteSubscription(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeSub(EventSubscription sub) {
    return Json.emptyObject
    .set("id", sub.id)
    .set("namespaceId", sub.namespaceId)
    .set("environmentId", sub.environmentId)
    .set("tenantId", sub.tenantId)
    .set("name", sub.name)
    .set("description", sub.description)
    .set("status", sub.status.to!string)
    .set("source", sub.source)
    .set("eventTypes", serializeStrArray(sub.eventTypes))
    .set("typeEncoding", sub.typeEncoding.to!string)
    .set("sinkUrl", sub.sinkUrl)
    .set("sinkServiceName", sub.sinkServiceName)
    .set("sinkServicePort", sub.sinkServicePort)
    .set("maxInFlightMessages", sub.maxInFlightMessages)
    .set("exactTypeMatching", sub.exactTypeMatching)
    .set("filterAttributes", sub.filterAttributes.toJson)
    .set("labels", sub.labels.toJson)  
    .set("createdBy", sub.createdBy)
    .set("createdAt", sub.createdAt)
    .set("updatedAt", sub.updatedAt);
  }
}
