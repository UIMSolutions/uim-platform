/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.schema;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct SchemaObject {
  string name;
  string objectType;
  long rowCount;
  long sizeBytes;

  Json toJson() const {
      return Json.emptyObject
          .set("name", name)
          .set("objectType", objectType)
          .set("rowCount", rowCount)
          .set("sizeBytes", sizeBytes);
  }
}

struct Schema {
  mixin TenantEntity!(SchemaId);

  DatabaseInstanceId instanceId;
  string name;
  string owner;
  SchemaType type;
  bool hasPrivileges;
  long tableCount;
  long viewCount;
  long procedureCount;
  long sizeBytes;

  Json toJson() const {
      return entityToJson
          .set("instanceId", instanceId.value)
          .set("name", name)
          .set("owner", owner)
          .set("type", type.to!string)
          .set("hasPrivileges", hasPrivileges)
          .set("tableCount", tableCount)
          .set("viewCount", viewCount)
          .set("procedureCount", procedureCount)
          .set("sizeBytes", sizeBytes);
  }
}
