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
  DeploymentRecordId id;
  TenantId tenantId;
  HtmlAppId appId;
  AppVersionId versionId;
  ServiceInstanceId serviceInstanceId;
  DeploymentOperation operation;
  DeploymentStatus status;
  string errorMessage;
  long startedAt;
  long completedAt;
  long createdAt;
  UserId deployedBy;
}
