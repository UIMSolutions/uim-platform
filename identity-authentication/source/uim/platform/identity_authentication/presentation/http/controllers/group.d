/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.controllers.group;

// import uim.platform.identity_authentication.application.usecases.manage.groups;
// import uim.platform.identity_authentication.application.dto;
// import uim.platform.identity_authentication.domain.entities.group;

import uim.platform.identity_authentication;

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
    auto createReq = CreateGroupRequest();
    createReq.tenantId = tenantId;
    createReq.name = data.getString("name");
    createReq.description = data.getString("description");

    auto result = useCase.createGroup(createReq);
    if (result.hasError)
      return errorResponse(result.error, 400);

    auto response = Json.emptyObject.set("id", result.groupId);
    return successResponse("Group created successfully", "Created", 201, response);
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
    return successResponse("Groups retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    // import std.string : lastIndexOf;

    auto path = req.requestURI;
    auto idx = path.lastIndexOf('/');
    auto groupId = GroupId(idx >= 0 ? path[idx + 1 .. $] : "");

    auto group = useCase.getGroup(tenantId, groupId);
    if (group.isNull) 
      return errorResponse("IAGroup not found", 404);
    

    auto response = group.toJson;
    return successResponse("Group retrieved successfully", "Retrieved", 200, response);
  }

  protected Json addMemberHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto groupId = GroupId(data.getString("groupId"));
    auto userId = UserId(data.getString("userId"));

    auto result = useCase.addMember(tenantId, groupId, userId);
    if (result.hasError) 
      return errorResponse(result.message, 400);
    

    auto response = Json.emptyObject.set("id", result.id);
    response["status"] = "member_added";
    return successResponse("Member added successfully", "OK", 200, response);
  }

  mixin(HandleTemplate!("handleAddMember", "addMemberHandler"));
}
