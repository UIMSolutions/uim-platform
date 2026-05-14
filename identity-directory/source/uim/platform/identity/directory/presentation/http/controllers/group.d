/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.group;




// import uim.platform.identity.directory.application.usecases.manage.groups;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.group;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for SCIM 2.0 group management.
class GroupController : PlatformController {
  private ManageGroupsUseCase useCase;

  this(ManageGroupsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/scim/Groups", &handleCreate);
    router.get("/scim/Groups", &handleList);
    router.get("/scim/Groups/*", &handleGet);
    router.put("/scim/Groups/*", &handleUpdate);
    router.delete_("/scim/Groups/*", &handleDelete);
    router.post("/scim/Groups/members", &handleAddMember);
    router.delete_("/scim/Groups/members", &handleDeleteMember);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      auto members = parseMembers(j);
      CreateGroupRequest createReq;
      createReq.tenantId = tenantId;
      createReq.externalId = j.getString("externalId");
      createReq.displayName = j.getString("displayName");
      createReq.description = j.getString("description");
      createReq.members = members;

      auto result = useCase.createGroup(createReq);

      if (result.isSuccess()) {
      auto response = Json.emptyObject
        .set("id", Json(result.groupId))
        .set("schemas", ["urn:ietf:params:scim:schemas:core:2.0:Group"].toJson);

        res.writeJsonBody(response, 201);
      } else {
        writeScimError(res, 409, result.error);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto groups = useCase.listGroups(tenantId);
      auto response = Json.emptyObject
      .set("schemas", ["urn:ietf:params:scim:api:messages:2.0:ListResponse"].toJson)
      .set("totalResults", Json(groups.length))
      .set("Resources", toJsonArray(groups));
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto groupId = extractIdFromPath(req.requestURI);
      auto group = useCase.getGroup(groupId);
      if (group == Group.init) {
        writeScimError(res, 404, "Group not found");
        return;
      }
      res.writeJsonBody(toJsonValue(group), 200);
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto groupId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto updateReq = UpdateGroupRequest(groupId, j.getString("displayName"),
        j.getString("description"),);
      auto error = useCase.updateGroup(updateReq);
      if (error.length > 0) {
        writeScimError(res, 404, error);
      } else {
        auto resp = Json.emptyObject
        .set("status", "updated");
        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto groupId = extractIdFromPath(req.requestURI);
      auto error = useCase.deleteGroup(groupId);
      if (error.length > 0)
        writeScimError(res, 404, error);
      else
        res.writeBody("", 204);
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  protected void handleAddMember(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto addReq = AddMemberRequest(tenantId, j.getString("groupId"),
        j.getString("memberId"), j.getString("memberType"), j.getString("display"),);
      auto error = useCase.addMember(addReq);
      if (error.length > 0) {
        writeScimError(res, 400, error);
      } else {
        auto resp = Json.emptyObject
          .set("status", "member_added");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  protected void handleDeleteMember(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto removeReq = RemoveMemberRequest(tenantId, j.getString("groupId"), j.getString("memberId"),);
      auto error = useCase.removeMember(removeReq);
      if (error.length > 0) {
        writeScimError(res, 400, error);
      } else {
        auto resp = Json.emptyObject
          .set("status", "member_removed");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }
}

private GroupMember[] parseMembers(Json j) {
  import uim.platform.identity.directory.domain.entities.group : GroupMember;

  GroupMember[] result;
  if (!j.isObject)
    return result;
  auto val = "members" in j;
  if (val.isNull || !(val).isArray)
    return result;
  foreach (item; *val) {
    result ~= GroupMember(item.getString("value"), item.getString("type"),
      item.getString("display"),);
  }
  return result;
}

private void writeScimError(scope HTTPServerResponse res, int status, string detail) {
  auto errRes = Json.emptyObject;
  errRes["schemas"] = Json.emptyArray;
  errRes["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:Error");
  errRes["detail"] = Json(detail);

  
  errRes["status"] = Json(status.to!string);
  res.writeJsonBody(errRes, status);
}
