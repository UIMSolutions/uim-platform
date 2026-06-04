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
class GroupController : ManageHttpController {
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

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto groups = useCase.listGroups(tenantId);
    auto list = groups.map!(g => toJsonValue(g)).array.toJson;

    auto response = Json.emptyObject
      .set("schemas", ["urn:ietf:params:scim:api:messages:2.0:ListResponse"].toJson)
      .set("totalResults", groups.length)
      .set("Resources", list);
    return successResponse("Group list retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto members = parseMembers(j);
    CreateGroupRequest createReq;
    createReq.tenantId = precheck.tenantId;
    createReq.externalId = data.getString("externalId");
    createReq.displayName = data.getString("displayName");
    createReq.description = data.getString("description");
    createReq.members = members;

    auto result = useCase.createGroup(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id)
      .set("schemas", ["urn:ietf:params:scim:schemas:core:2.0:Group"].toJson);

    return successResponse("Scan job created successfully", "Created", 201, responseData);
  }
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = GroupId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid group ID", 400);

  auto group = useCase.getGroup(tenantId, id);
  if (group.isNull)
    return errorResponse("Group not found", 404);

  auto responseData = group.toJson();
  return successResponse("Group retrieved successfully", "Retrieved", 200, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto groupId = precheck.id;
    auto data = precheck.data;
    auto updateReq = UpdateGroupRequest(groupId, data.getString("displayName"),
      data.getString("description"),);
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

override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto groupId = precheck.id;
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
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto addReq = AddMemberRequest(tenantId, data.getString("groupId"),
      data.getString("memberId"), data.getString("memberType"), data.getString("display"),);
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

override protected void handleDeleteMember(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto removeReq = RemoveMemberRequest(tenantId, data.getString("groupId"), data.getString("memberId"),);
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
