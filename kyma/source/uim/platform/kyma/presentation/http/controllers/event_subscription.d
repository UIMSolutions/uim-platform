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
class EventSubscriptionController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateEventSubscriptionRequest r;
      r.namespaceId = data.getString("namespaceId");
      r.environmentId = data.getString("environmentId");
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.source = data.getString("source");
      r.eventTypes = data.getStrings("eventTypes");
      r.typeEncoding = data.getString("typeEncoding");
      r.sinkUrl = data.getString("sinkUrl");
      r.sinkServiceName = data.getString("sinkServiceName");
      r.sinkServicePort = data.getInteger("sinkServicePort");
      r.maxInFlightMessages = data.getInteger("maxInFlightMessages");
      r.exactTypeMatching = data.getBoolean("exactTypeMatching", true);
      r.filterAttributes = data.jsonStrMap("filterAttributes");
      r.labels = data.jsonStrMap("labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
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

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateEventSubscriptionRequest r;
      r.description = data.getString("description");
      r.eventTypes = data.getStrings("eventTypes");
      r.sinkUrl = data.getString("sinkUrl");
      r.sinkServiceName = data.getString("sinkServiceName");
      r.sinkServicePort = data.getInteger("sinkServicePort");
      r.maxInFlightMessages = data.getInteger("maxInFlightMessages");
      r.exactTypeMatching = data.getBoolean("exactTypeMatching", true);
      r.filterAttributes = data.jsonStrMap("filterAttributes");
      r.labels = data.jsonStrMap("labels");

      auto result = usecase.updateSubscription(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.pauseSubscription(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.resumeSubscription(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteSubscription(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
