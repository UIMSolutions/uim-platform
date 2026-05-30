/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.user_profile;



// import uim.platform.workzone.application.usecases.manage.user_profiles;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.user_profile;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class UserProfileController : ManageController {
  private ManageUserProfilesUseCase useCase;

  this(ManageUserProfilesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/user-profiles", &handleCreate);
    router.get("/api/v1/user-profiles", &handleList);
    router.get("/api/v1/user-profiles/*", &handleGet);
    router.put("/api/v1/user-profiles/*", &handleUpdate);
    router.delete_("/api/v1/user-profiles/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateUserProfileRequest();
      r.tenantId = tenantId;
      r.userId = data.getString("userId");
      r.displayName = data.getString("displayName");
      r.email = data.getString("email");
      r.firstName = data.getString("firstName");
      r.lastName = data.getString("lastName");
      r.jobTitle = data.getString("jobTitle");
      r.department = data.getString("department");
      r.timezone = data.getString("timezone");
      r.language = data.getString("language");

      auto result = useCase.createUserProfile(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "User profile created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto profiles = useCase.listProfiles(tenantId);
      auto arr = profiles.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(profiles.length))
        .set("message", "User profiles retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto p = useCase.getUserProfile(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "User profile not found");
        return;
      }
      res.writeJsonBody(p.toJson, 200);
    } catch (Exception e) {
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
      auto r = UpdateUserProfileRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.displayName = data.getString("displayName");
      r.email = data.getString("email");
      r.jobTitle = data.getString("jobTitle");
      r.avatarUrl = data.getString("avatarUrl");

      auto result = useCase.updateUserProfile(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteUserProfile(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
