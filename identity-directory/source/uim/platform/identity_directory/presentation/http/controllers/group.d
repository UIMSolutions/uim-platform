/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.http.controllers.group;

// import uim.platform.identity_directory.application.usecases.manage.groups;

// import uim.platform.identity_directory.domain.entities.group;
import uim.platform.identity_directory;

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
    return successResponse("IAMGroup list retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto members = parseMembers(j);
    CreateGroupRequest createReq;
    createReq.tenantId = tenantId;
    createReq.externalId = data.getString("externalId");
    createReq.displayName = data.getString("displayName");
    createReq.description = data.getString("description");
    createReq.members = members;

    auto result = useCase.createGroup(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id)
      .set("schemas", ["urn:ietf:params:scim:schemas:core:2.0:IAMGroup"].toJson);

    return successResponse("Scan job created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = IAMGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid group ID", 400);

    auto group = useCase.getGroup(tenantId, id);
    if (group.isNull)
      return errorResponse("IAMGroup not found", 404);

    auto responseData = group.toJson();
    return successResponse("IAMGroup retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto groupId = IAMGroupId(precheck.id);
    if (groupId.isNull)
      return errorResponse("Invalid group ID", 400);

    auto data = precheck.data;
    auto updateReq = UpdateGroupRequest(groupId, data.getString("displayName"),
      data.getString("description"),);
    auto result = useCase.updateGroup(updateReq);
    if (result.hasError)
      writeScimError(res, 404, result.errorMessage);

    return successResponse("IAMGroup updated successfully", "Updated", 200, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = IAMGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid group ID", 400);

    auto result = useCase.deleteGroup(tenantId, id);
    if (result.hasError)
      return errorResponse(result.errorMessage, 404);

    return successResponse("IAMGroup deleted successfully", "Deleted", 200, Json.emptyObject);
  }

  protected Json addMemberHandler(HTTPServerRequest req) {
    auto precheck = super.POSTHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto addReq = AddMemberRequest(tenantId, data.getString("groupId"),
      data.getString("memberId"), data.getString("memberType"), data.getString("display"),);
    auto result = useCase.addMember(addReq);
    if (result.hasError)
      return errorResponse(result.errorMessage, 400);

    // if (error.length > 0) {
    //   writeScimError(res, 400, error);
    //   return Json.emptyObject;
    // } else {
    //   auto resp = Json.emptyObject
    //     .set("status", "member_added");

    return successResponse("Member added successfully", "Added", 200, Json.emptyObject.set("id", result
        .id));
  }
}

mixin(HandleTemplate!("handleAddMember", "addMemberHandler"));

protected Json deleteMemberHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto data = precheck.data;
  auto removeReq = RemoveMemberRequest(tenantId, data.getString("groupId"), data.getString("memberId"),);
  auto result = useCase.removeMember(removeReq);
  if (result.hasError)
    return errorResponse(result.errorMessage, 400);

  return successResponse("Member removed successfully", "Removed", 200, Json.emptyObject);
}

mixin(HandleTemplate!("handleDeleteMember", "deleteMemberHandler"));

private GroupMember[] parseMembers(Json j) {
  import uim.platform.identity_directory.domain.entities.group : GroupMember;

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
