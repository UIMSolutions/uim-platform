/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.entities.group;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Member reference within a group.
struct GroupMember {
  string value; // user or group ID
  string type; // "User" or "Group"
  string display;

  Json toJson() const {
    return Json.emptyObject
      .set("value", value)
      .set("type", type)
      .set("display", display);
  }
}
/// SCIM 2.0 group entity.
struct IDGroup {
  mixin TenantEntity!GroupId;

  string externalId;
  string displayName;
  string description;
  GroupType groupType = GroupType.standard;
  GroupMember[] members;
  string[] schemas;
  long createdAt;
  long updatedAt;

  /// Number of members.
  size_t memberCount() const {
    return members.length;
  }

  /// Check if a user is a member.
  bool hasMember(UserId userId) const {
    return hasMember(userId.value);
  }

  // bool hasMember(GroupId groupId) const {
  //   return members.any!(m => m.value == groupId.value && m.type == "Group");
  // }

  bool hasMember(string memberId) const {
    return members.any!(m => m.value == memberId && m.type == "User");
  }


  Json toJson() const {
    return entityToJson
      .set("externalId", externalId)
      .set("displayName", displayName)
      .set("description", description)
      .set("groupType", groupType.to!string())
      .set("members", members.map!(m => m.toJson()).array.toJson)
      .set("schemas", schemas.map!(s => Json(s)).array.toJson);
  }
}
