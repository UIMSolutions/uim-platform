/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.space;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct SpaceLabel {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct StorageAssignment {
  StorageType type;
  long quotaBytes;
  long usedBytes;

  Json toJson() const {
    return Json.emptyObject
      .set("type", type.to!string)
      .set("quotaBytes", quotaBytes)
      .set("usedBytes", usedBytes);
  }
}

struct SpaceMember {
  string userId;
  string role;

  Json toJson() const {
    return Json.emptyObject
      .set("userId", userId)
      .set("role", role);
  }
}

struct Space {
  mixin TenantEntity!(SpaceId);
  
  string name;
  string description;
  string businessName;
  StorageAssignment[] storage;
  SpaceMember[] members;
  SpaceLabel[] labels;
  int priority;
  bool enableAuditLog;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("businessName", businessName)
      .set("storage", storage.map!(s => s.toJson()).array.toJson)
      .set("members", members.map!(m => m.toJson()).array.toJson)
      .set("labels", labels.map!(l => l.toJson()).array.toJson)
      .set("priority", priority)
      .set("enableAuditLog", enableAuditLog);
  }
}
