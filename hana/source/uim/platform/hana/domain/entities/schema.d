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
}

struct Schema {
  SchemaId id;
  TenantId tenantId;
  InstanceId instanceId;
  string name;
  string owner;
  SchemaType type;
  bool hasPrivileges;
  long tableCount;
  long viewCount;
  long procedureCount;
  long sizeBytes;
  long createdAt;
  long modifiedAt;
}
