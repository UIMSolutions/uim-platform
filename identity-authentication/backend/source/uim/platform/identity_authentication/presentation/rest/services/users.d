/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.rest.services.users;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Implementation of IUserApi on top of the driving port.
class UserRestService : IUserApi {
  private IManageUsersUseCase users;

  this(IManageUsersUseCase users) {
    this.users = users;
  }

  Json[] getUsers(RequestIdentity identity) {
    return users.listUsers(identity.tenantId).map!(u => u.toJson).array;
  }

  Json getUser(string _id, RequestIdentity identity) {
    return require(identity.tenantId, _id).toJson;
  }

  Json createUser(Json request, RequestIdentity identity) {
    UserDTO dto;
    read(dto, request);
    dto.tenantId = identity.tenantId;
    dto.createdBy = identity.userId;
    return respond(users.createUser(dto));
  }

  Json updateUser(string _id, Json request, RequestIdentity identity) {
    auto dto = UserDTO.fromEntity(require(identity.tenantId, _id));
    read(dto, request);
    dto.userId = UserId(_id);
    dto.password = "";
    dto.tenantId = identity.tenantId;
    dto.updatedBy = identity.userId;
    return respond(users.updateUser(dto));
  }

  Json lockUser(string _id, RequestIdentity identity) {
    return respond(users.setUserStatus(identity.tenantId, UserId(_id), UserStatus.locked, identity.userId));
  }

  Json unlockUser(string _id, RequestIdentity identity) {
    return respond(users.setUserStatus(identity.tenantId, UserId(_id), UserStatus.active, identity.userId));
  }

  void deleteUser(string _id, RequestIdentity identity) {
    respond(users.deleteUser(identity.tenantId, UserId(_id)));
  }

  private IAUser require(TenantId tenantId, string id) {
    auto user = users.getUser(tenantId, UserId(id));
    if (user.isNull)
      throw new HTTPStatusException(HTTPStatus.notFound, "User '" ~ id ~ "' not found");
    return user;
  }

  private static void read(ref UserDTO dto, Json request) {
    try
      readPayload(dto, request);
    catch (PayloadException e)
      throw new HTTPStatusException(HTTPStatus.badRequest, e.msg);
  }

  private static Json respond(UsecaseResult result) {
    if (!result.isSuccess)
      throw new HTTPStatusException(cast(HTTPStatus) httpStatusOf(result), result.message);
    return Json.emptyObject.set("id", result.id).set("message", result.message);
  }
}
