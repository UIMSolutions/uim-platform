/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.user_profile;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.user_profiles;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.user_profile;
import uim.platform.identity_authentication.presentation.http.json_utils;

class UserProfileController {
  private ManageUserProfilesUseCase useCase;

  this(ManageUserProfilesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/user-profiles", &handleCreate);
    router.get("/api/v1/user-profiles", &handleList);
    router.get("/api/v1/user-profiles/*", &handleGet);
    router.put("/api/v1/user-profiles/*", &handleUpdate);
    router.delete_("/api/v1/user-profiles/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      auto r = CreateUserProfileRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.userId = j.getString("userId");
      r.displayName = j.getString("displayName");
      r.email = j.getString("email");
      r.firstName = j.getString("firstName");
      r.lastName = j.getString("lastName");
      r.jobTitle = j.getString("jobTitle");
      r.department = j.getString("department");
      r.timezone = j.getString("timezone");
      r.language = j.getString("language");

      auto result = useCase.createUserProfile(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto profiles = useCase.listProfiles(tenantId);
      auto arr = Json.emptyArray;
      foreach (ref p; profiles)
        arr ~= serializeUserProfile(p);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) profiles.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto p = useCase.getUserProfile(id, tenantId);
      if (p is null)
      {
        writeError(res, 404, "User profile not found");
        return;
      }
      res.writeJsonBody(serializeUserProfile(*p), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateUserProfileRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.displayName = j.getString("displayName");
      r.email = j.getString("email");
      r.jobTitle = j.getString("jobTitle");
      r.avatarUrl = j.getString("avatarUrl");

      auto result = useCase.updateUserProfile(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteUserProfile(id, tenantId);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }
}
