/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.object_version;

// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
struct ObjectVersion {
  mixin TenantEntity!ObjectVersionId;

  ObjectId objectId;
  string versionTag; // e.g. "v1", "v2", auto-incremented label
  long size;
  string etag;
  string contentType;
  bool isLatest;
  bool isDeleteMarker;
  UserId createdBy;

  Json toJson() const {
    return entityToJson
      .set("objectId", objectId)
      .set("versionTag", versionTag)
      .set("size", size)
      .set("etag", etag)
      .set("contentType", contentType)
      .set("isLatest", isLatest)
      .set("isDeleteMarker", isDeleteMarker);
  }
}
