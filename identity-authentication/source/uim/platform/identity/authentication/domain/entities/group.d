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
  mixin TenantEntity!GroupId;

  string name;
  string description;
  string[] memberUserIds;
 
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("memberUserIds", memberUserIds);
  }
}
