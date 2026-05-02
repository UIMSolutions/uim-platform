module uim.platform.abap_environment.application.dtos.business_user;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

struct CreateBusinessUserRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string username;
  string firstName;
  string lastName;
  string email;
  string[] roleIds;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("username", username)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("email", email)
      .set("roleIds", roleIds.toJson);
  }
}

struct UpdateBusinessUserRequest {
  string firstName;
  string lastName;
  string email;
  string status; // "active", "inactive", "locked"
  string[] roleIds;

  Json toJson() const {
    return Json.emptyObject
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("email", email)
      .set("status", status)
      .set("roleIds", roleIds.toJson);
  }
}