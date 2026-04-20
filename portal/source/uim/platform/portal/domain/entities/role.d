/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.role;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Role for portal access — controls what content users can see.
struct Role {
  mixin TenantEntity!(RoleId);

  string name;
  string description;
  RoleScope scope_ = RoleScope.site;
  string[] userIds;
  string[] groupIds;
  
  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("description", description)
      .set("scope", scope_)
      .set("userIds", userIds)
      .set("groupIds", groupIds);

    return j;
  }
}
