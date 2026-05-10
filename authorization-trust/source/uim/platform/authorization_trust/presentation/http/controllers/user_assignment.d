/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.user_assignment;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class UserAssignmentController : PlatformController {
  private ManageUserAssignmentsUseCase usecase;

  this(ManageUserAssignmentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/user-assignments",    &handleCreate);
    router.get("/api/v1/user-assignments",     &handleList);
    router.get("/api/v1/user-assignments/*",   &handleGet);
    router.delete_("/api/v1/user-assignments/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateUserAssignmentRequest r;
      r.userId           = j.getString("userId");
      r.userEmail        = j.getString("userEmail");
      r.roleCollectionId = j.getString("roleCollectionId");
      r.origin           = j.getString("origin");

      auto result = usecase.create(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto userId = req.params.get("userId", "");
      auto assignments = userId.length > 0 ? usecase.listByUserId(userId) : usecase.listAll();
      auto jarr = Json.emptyArray;
      foreach (ua; assignments)
        jarr ~= uaToJson(ua);
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", assignments.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto ua = usecase.getById(id);
      if (ua.id.length == 0) {
        writeError(res, 404, "User assignment not found");
        return;
      }
      res.writeJsonBody(uaToJson(ua), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto result = usecase.remove(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", id), 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json uaToJson(UserAssignmentEntity ua) @safe {
    return Json.emptyObject
      .set("id",               ua.id)
      .set("userId",           ua.userId)
      .set("userEmail",        ua.userEmail)
      .set("roleCollectionId", ua.roleCollectionId)
      .set("origin",           ua.origin)
      .set("createdAt",        ua.createdAt);
  }
}
