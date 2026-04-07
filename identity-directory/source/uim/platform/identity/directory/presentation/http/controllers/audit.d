/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.audit;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.identity.directory.application.usecases.query_audit_log;
import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity_authentication.presentation.http.json_utils;

/// HTTP controller for audit log queries.
class AuditController {
  private QueryAuditLogUseCase useCase;

  this(QueryAuditLogUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/audit-logs", &handleList);
    router.get("/api/v1/audit-logs/actor/*", &handleByActor);
    router.get("/api/v1/audit-logs/target/*", &handleByTarget);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto events = useCase.listEvents(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long) events.length);
      response["resources"] = toJsonArray(events);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleByActor(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto actorId = extractIdFromPath(req.requestURI);
      auto events = useCase.findByActor(actorId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long) events.length);
      response["resources"] = toJsonArray(events);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleByTarget(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto targetId = extractIdFromPath(req.requestURI);
      auto events = useCase.findByTarget(targetId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long) events.length);
      response["resources"] = toJsonArray(events);
      res.writeJsonBody(response, 200);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}
