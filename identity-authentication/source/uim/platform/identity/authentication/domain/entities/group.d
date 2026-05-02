/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.group;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// IdaGroup entity for organizing users.
struct IdaGroup {
  GroupId id;
  TenantId tenantId;
  string name;
  string description;
  string[] memberUserIds;
  long createdAt;
  long updatedAt;

  Json toJson() {
    return Json.emptyObject.set("id", id.value).set("tenantId", tenantId).set("name",
        name).set("description", description).set("memberUserIds",
        memberUserIds).set("createdAt", createdAt).set("updatedAt", updatedAt);
  }
}
