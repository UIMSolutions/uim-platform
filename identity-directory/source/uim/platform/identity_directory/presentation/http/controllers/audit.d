/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.http.controllers.audit;

// import uim.platform.identity_directory.application.usecases.query_audit_log;
// import uim.platform.identity_directory.domain.entities.audit_event;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for audit log queries.
class AuditController : ManageHttpController {
  private QueryAuditLogUseCase useCase;

  this(QueryAuditLogUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/audit-logs", &handleList);
    router.get("/api/v1/audit-logs/actor/*", &handleByActor);
    router.get("/api/v1/audit-logs/target/*", &handleByTarget);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto events = useCase.listEvents(tenantId);
    auto list = events.map!(e => e.toJson).array.toJson;

    auto response = Json.emptyObject
      .set("totalResults", events.length)
      .set("resources", list);
    return successResponse("Audit log list retrieved successfully", "Retrieved", 200, response);
  }

  protected Json actorHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    if (id.isEmpty)
      return errorResponse("Invalid actor ID", 400);

    auto events = useCase.findByActor(tenantId, id);
    auto list = events.map!(e => e.toJson).array.toJson;

    auto response = Json.emptyObject
      .set("totalResults", events.length)
      .set("resources", list);
    return successResponse("Audit log list retrieved successfully", "Retrieved", 200, response);
  }

  mixin(HandleTemplate!("handleByActor", "actorHandler"));

  protected Json targetHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    if (id.isEmpty)
      return errorResponse("Invalid target ID", 400);

    auto events = useCase.findByTarget(tenantId, id);
    auto list = events.map!(e => e.toJson).array.toJson;

    auto response = Json.emptyObject
      .set("totalResults", events.length)
      .set("resources", list);
    return successResponse("Audit log list retrieved successfully", "Retrieved", 200, response);
  }

  mixin(HandleTemplate!("handleByTarget", "targetHandler"));

}
