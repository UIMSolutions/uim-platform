/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.enumerations;

import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:


// Application visibility
enum AppVisibility {
  private_,   // accessible only within same space
  public_,    // shared across spaces
}
AppVisibility toAppVisibility(string s) {
    const map = [
        "private": AppVisibility.private_,
        "public": AppVisibility.public_
    ];
    return map.get(s.toLower, AppVisibility.private_);
}

// Application status
enum AppStatus {
  active,
  inactive,
  deleted_,
}
AppStatus toAppStatus(string s) {
    const map = [
        "active": AppStatus.active,
        "inactive": AppStatus.inactive,
        "deleted": AppStatus.deleted_
    ];
    return map.get(s.toLower, AppStatus.inactive);
}

// Version status
enum VersionStatus {
  active,
  superseded,
  archived,
}
VersionStatus toVersionStatus(string s) {
    const map = [
        "active": VersionStatus.active,
        "superseded": VersionStatus.superseded,
        "archived": VersionStatus.archived
    ];
    return map.get(s.toLower, VersionStatus.active);
}

// Deployment status
enum DeploymentStatus {
  pending,
  inProgress,
  completed,
  failed,
  rolledBack,
}
DeploymentStatus toDeploymentStatus(string s) {
    const map = [
        "pending": DeploymentStatus.pending,
        "inprogress": DeploymentStatus.inProgress,
        "completed": DeploymentStatus.completed,
        "failed": DeploymentStatus.failed,
        "rolledback": DeploymentStatus.rolledBack
    ];
    return map.get(s.toLower, DeploymentStatus.pending);
}
// Deployment operation type
enum DeploymentOperation {
  deploy,
  undeploy,
  redeploy,
}
// Service plan type
enum ServicePlan {
  appHost,     // for deploying HTML5 apps
  appRuntime,  // for accessing HTML5 apps at runtime
}
// Service instance status
enum InstanceStatus {
  active,
  suspended,
  deleted_,
}
// Cache status
enum CacheStatus {
  valid,
  stale,
  expired,
}
// Content type category (for file classification)
enum FileCategory {
  html,
  css,
  javascript,
  image,
  font,
  json,
  xml,
  other,
}
// Route status
enum RouteStatus {
  active,
  inactive,
}
