/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.controllers.group;



// import uim.platform.identity.authentication.application.usecases.manage.groups;
// import uim.platform.identity.authentication.application.dto;
// import uim.platform.identity.authentication.domain.entities.group;

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// HTTP controller for group management API.
class GroupController : ManageHttpController {
  private ManageGroupsUseCase useCase;

  this(ManageGroupsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/groups", &handleCreate);
    router.get("/api/v1/groups", &handleList);
    router.get("/api/v1/groups/*", &handleGet);
    router.post("/api/v1/groups/members", &handleAddMember);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateGroupRequest(data.getString("tenantId"),
        data.getString("name"), data.getString("description"));

      auto result = useCase.createGroup(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["groupId"] = Json(result.groupId);
        res.writeJsonBody(response, 201);
      } else {
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 400);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto groups = useCase.listGroups(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = groups.length.toJson;
      response["resources"] = groups.toJson;
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      // import std.string : lastIndexOf;
      auto tenantId = precheck.tenantId;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      auto groupId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto group = useCase.getGroup(groupId);
      if (group == IdaGroup.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("IdaGroup not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      res.writeJsonBody(toJsonValue(group), 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleAddMember(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      auto data = precheck.data;
      auto error = useCase.addMember(data.getString("groupId"), data.getString("userId"));

      if (error.length > 0) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 400);
      } else {
        auto resp = Json.emptyObject
          .set("status", "member_added");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}
