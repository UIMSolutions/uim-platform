/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.user_assignment;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class UserAssignmentController : ManageHttpController {
  private ManageUserAssignmentsUseCase usecase;

  this(ManageUserAssignmentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/user-assignments", &handleCreate);
    router.get("/api/v1/user-assignments", &handleList);
    router.get("/api/v1/user-assignments/*", &handleGet);
    router.delete_("/api/v1/user-assignments/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateUserAssignmentRequest r;
    r.tenantId = tenantId;
    r.userId = data.getString("userId");
    r.userEmail = data.getString("userEmail");
    r.roleCollectionId = RoleCollectionId(data.getString("roleCollectionId"));
    r.origin = data.getString("origin");

    auto result = usecase.createAssignment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("User assignment created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto userId = UserId(req.query.get("userId", ""));

    auto assignments =
      userId.isEmpty ? usecase.listAssignments(
        tenantId) : usecase.listAssignments(tenantId, userId);

    auto list = assignments.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("User assignment list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = UserAssignmentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid user assignment ID", 400);

    auto ua = usecase.getAssignment(tenantId, id);
    if (ua.isNull)
      return errorResponse("User assignment not found", 404);

    auto responseData = ua.toJson();
    return successResponse("User assignment retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = UserAssignmentId(precheck.id);

    auto result = usecase.deleteAssignment(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("User assignment deleted successfully", "Deleted", 200, responseData);
  }
}
