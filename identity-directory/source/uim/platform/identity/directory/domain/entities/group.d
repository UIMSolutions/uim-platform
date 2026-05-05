/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.entities.group;

// import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory;

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
struct Group {
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
  ulong memberCount() const {
    return members.length;
  }

  /// Check if a user is a member.
  bool hasMember(string userId) const {
    foreach (m; members) {
      if (m.value == userId)
        return true;
    }
    return false;
  }

  Json toJson() const {
    return entityToJson
      .set("externalId", externalId)
      .set("displayName", displayName)
      .set("description", description)
      .set("groupType", groupType.to!string)
      .set("members", members.map!(m => m.toJson()).array)
      .set("schemas", schemas);
  }
}
