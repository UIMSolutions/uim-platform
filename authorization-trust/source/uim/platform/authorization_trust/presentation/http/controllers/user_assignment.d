/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.user_assignment;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class UserAssignmentController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateUserAssignmentRequest r;
      r.tenantId = tenantId;
      r.userId = UserId(j.getString("userId"));
      r.userEmail = j.getString("userEmail");
      r.roleCollectionId = RoleCollectionId(j.getString("roleCollectionId"));
      r.origin = j.getString("origin");

      auto result = usecase.createUserAssignment(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto userId = UserId(req.params.get("userId", ""));

      auto assignments =
        userId.isEmpty ? usecase.listUserAssignments(
          tenantId) : usecase.listUserAssignments(tenantId, userId);

      auto jarr = assignments.map!(ua => ua.toJson).array.toJson;

      auto response = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", assignments.length)
        .set("message", "User assignments retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = UserAssignmentId(extractIdFromPath(req));

      auto ua = usecase.getUserAssignment(tenantId, id);
      if (ua.isNull) {
        writeError(res, 404, "User assignment not found");
        return;
      }

      auto response = Json.emptyObject
        .set("result", ua.toJson)
        .set("message", "User assignment retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = UserAssignmentId(extractIdFromPath(req));

      auto result = usecase.deleteUserAssignment(tenantId, id);
      if (result.success) {
        auto response = Json.emptyObject
          .set("result", Json.emptyObject.set("id", id))
          .set("message", "User assignment deleted successfully");

        res.writeJsonBody(response, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
