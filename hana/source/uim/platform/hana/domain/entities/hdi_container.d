/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.hdi_container;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct HDIArtifact {
  string name;
  string artifactType;
  string path;
  long sizeBytes;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("artifactType", artifactType)
      .set("path", path)
      .set("sizeBytes", sizeBytes);
  }
}

struct HDIContainer {
  mixin TenantEntity!(HDIContainerId);

  DatabaseInstanceId instanceId;
  string name;
  string description;
  HDIContainerStatus status;
  string schemaName;
  string appUser;
  string appUserSchema;
  int artifactCount;
  long sizeBytes;
  string[] grantedSchemas;
  
  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.toString())
      .set("schemaName", schemaName)
      .set("appUser", appUser)
      .set("appUserSchema", appUserSchema)
      .set("artifactCount", artifactCount)
      .set("sizeBytes", sizeBytes)
      .set("grantedSchemas", grantedSchemas.array);
  }
}
