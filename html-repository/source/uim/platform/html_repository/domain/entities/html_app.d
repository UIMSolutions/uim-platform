/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.html_app;

// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct HtmlApp {
  HtmlAppId id;
  TenantId tenantId;
  SpaceId spaceId;
  ServiceInstanceId serviceInstanceId;
  string name;             // app technical name e.g. "com.sap.myapp"
  string namespace_;       // optional namespace
  string description;
  AppVisibility visibility;
  AppStatus status;
  string activeVersionId;  // currently active version
  long totalSizeBytes;     // total storage used
  long createdAt;
  long updatedAt;
  UserId createdBy;
  UserId updatedBy;
}
