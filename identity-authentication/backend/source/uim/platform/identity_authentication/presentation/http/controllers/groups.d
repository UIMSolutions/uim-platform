/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for groups:
///   GET/POST {api}/groups   GET/PUT/PATCH/DELETE {api}/groups/:id
///   GET/POST {api}/groups/:id/members {"userId"}   DELETE {api}/groups/:id/members/:userId
///   POST {api}/groups/members {"groupId","userId"}  (compatibility)
module uim.platform.identity_authentication.presentation.http.controllers.groups;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class GroupController : IdentityHttpController {
  protected IManageGroupsUseCase groups;

  this(IManageGroupsUseCase groups, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "groups", defaultTenant, verifier);
    this.groups = groups;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/members", &addMemberCompat);
    crudRoutes(router, &list, &get, &create, &update, &remove);
    router.get(basePath ~ "/:id/members", &listMembers);
    router.post(basePath ~ "/:id/members", &addMember);
    router.delete_(basePath ~ "/:id/members/:userId", &removeMember);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyList(res, groups.listGroups(identity(req).tenantId), "Groups"));
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, groups.getGroup(identity(req).tenantId, GroupId(id)), "Group", id);
    });
  }

  void create(HTTPServerRequest req, HTTPServerResponse res) {
    createWith!GroupDTO(req, res, (dto) => groups.createGroup(dto));
  }

  void update(HTTPServerRequest req, HTTPServerResponse res) {
    mergeWith!(GroupDTO, IAGroup)(req, res, "Group", (t, id) => groups.getGroup(t, GroupId(id)),
      (dto) => groups.updateGroup(dto));
  }

  void remove(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, groups.deleteGroup(identity(req).tenantId, GroupId(param(req, "id")))));
  }

  void listMembers(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyList(res, groups.listMembers(identity(req).tenantId, GroupId(param(req, "id"))), "Members"));
  }

  void addMember(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, groups.addMember(identity(req).tenantId, GroupId(param(req, "id")),
        UserId(stringOf(body(req), "userId")))));
  }

  void addMemberCompat(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto b = body(req);
      replyResult(res, groups.addMember(identity(req).tenantId, GroupId(stringOf(b, "groupId")),
        UserId(stringOf(b, "userId"))));
    });
  }

  void removeMember(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, groups.removeMember(identity(req).tenantId, GroupId(param(req, "id")),
        UserId(param(req, "userId")))));
  }
}
