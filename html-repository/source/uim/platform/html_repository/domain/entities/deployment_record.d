/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.deployment_record;

// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct DeploymentRecord {
  mixin TenantEntity!DeploymentRecordId;

  HtmlAppId appId;
  AppVersionId versionId;
  ServiceInstanceId serviceInstanceId;
  DeploymentOperation operation;
  DeploymentStatus status;
  string errorMessage;
  long startedAt;
  long completedAt;
  UserId deployedBy;

  Json toJson() const {
    return entityToJson
      .set("appId", appId)
      .set("versionId", versionId)
      .set("serviceInstanceId", serviceInstanceId)
      .set("operation", operation.to!string)
      .set("status", status.to!string)
      .set("errorMessage", errorMessage)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("createdAt", createdAt)
      .set("deployedBy", deployedBy);
  }
}
