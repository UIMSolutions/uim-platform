/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.enumerations;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

// Application visibility
enum AppVisibility : string {
  private_ = "private", // accessible only within same space
  public_ = "public", // shared across spaces
}

AppVisibility toAppVisibility(string value) {
  switch (value.toLower) {
  case "private":
    return AppVisibility.private_;
  case "public":
    return AppVisibility.public_;
  default:
    return AppVisibility.private_; // Default value for unknown strings is "private"
  }
}

AppVisibility[] toAppVisibilities(string[] values) {
  return values.map!(toAppVisibility).array;
}

string toString(AppVisibility value) {
  return cast(string)value;
}

string[] toStrings(AppVisibility[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("AppVisibility"));

  assert(toAppVisibility("private") == AppVisibility.private_);
  assert(toAppVisibility("public") == AppVisibility.public_);

  assert(toAppVisibility("") == AppVisibility.private_);
  assert(toAppVisibility("unknown") == AppVisibility.private_);

  assert(toString(AppVisibility.private_) == "private");
  assert(toString(AppVisibility.public_) == "public");

  assert(toStrings([AppVisibility.private_, AppVisibility.public_]) == [
      "private", "public"
    ]);
  assert(toAppVisibilities(["private", "public"]) == [
      AppVisibility.private_, AppVisibility.public_
    ]);
}

// Application status
enum AppStatus : string {
  active = "active",
  inactive = "inactive",
  deleted_ = "deleted",
}

AppStatus toAppStatus(string value) {
  switch (value.toLower) {
  case "active":
    return AppStatus.active;
  case "inactive":
    return AppStatus.inactive;
  case "deleted":
    return AppStatus.deleted_;
  default:
    return AppStatus.active; // Default value for unknown strings is "active"
  }
}
///
unittest {
  mixin(ShowTest!("AppStatus"));

  assert(toAppStatus("active") == AppStatus.active);
  assert(toAppStatus("inactive") == AppStatus.inactive);
  assert(toAppStatus("deleted") == AppStatus.deleted_);

  assert(toAppStatus("") == AppStatus.active);
  assert(toAppStatus("unknown") == AppStatus.active);

  assert(toString(AppStatus.active) == "active");
  assert(toString(AppStatus.inactive) == "inactive");
  assert(toString(AppStatus.deleted_) == "deleted");

  assert(toStrings([AppStatus.active, AppStatus.inactive, AppStatus.deleted_]) == [
      "active", "inactive", "deleted"
    ]);
  assert(toAppStatuses(["active", "inactive", "deleted"]) == [
      AppStatus.active, AppStatus.inactive, AppStatus.deleted_
    ]);
}

// Version status
enum VersionStatus {
  active,
  superseded,
  archived,
}

VersionStatus toVersionStatus(string value) {
  mixin(EnumSwitch("VersionStatus", "active"));
}

VersionStatus[] toVersionStatuses(string[] values) {
  return values.map!(toVersionStatus).array;
}

string toString(VersionStatus value) {
  return value.to!string;
}

string[] toStrings(VersionStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("VersionStatus"));

  assert(toVersionStatus("active") == VersionStatus.active);
  assert(toVersionStatus("superseded") == VersionStatus.superseded);
  assert(toVersionStatus("archived") == VersionStatus.archived);

  assert(toString(VersionStatus.active) == "active");
  assert(toString(VersionStatus.superseded) == "superseded");
  assert(toString(VersionStatus.archived) == "archived");

  assert(toStrings([
      VersionStatus.active, VersionStatus.superseded, VersionStatus.archived
    ]) == ["active", "superseded", "archived"]);
  assert(toVersionStatuses(["active", "superseded", "archived"]) == [
      VersionStatus.active, VersionStatus.superseded, VersionStatus.archived
    ]);
}

// Deployment status
enum DeploymentStatus {
  pending,
  inProgress,
  completed,
  failed,
  rolledBack,
}

DeploymentStatus toDeploymentStatus(string value) {
  mixin(EnumSwitch("DeploymentStatus", "pending"));
}

DeploymentStatus[] toDeploymentStatuses(string[] values) {
  return values.map!(toDeploymentStatus).array;
}

string toString(DeploymentStatus value) {
  return value.to!string;
}

string[] toStrings(DeploymentStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DeploymentStatus"));

  assert(toDeploymentStatus("pending") == DeploymentStatus.pending);
  assert(toDeploymentStatus("inProgress") == DeploymentStatus.inProgress);
  assert(toDeploymentStatus("completed") == DeploymentStatus.completed);
  assert(toDeploymentStatus("failed") == DeploymentStatus.failed);
  assert(toDeploymentStatus("rolledBack") == DeploymentStatus.rolledBack);

  assert(toDeploymentStatus("") == DeploymentStatus.pending);
  assert(toDeploymentStatus("unknown") == DeploymentStatus.pending);

  assert(toString(DeploymentStatus.pending) == "pending");
  assert(toString(DeploymentStatus.inProgress) == "inProgress");
  assert(toString(DeploymentStatus.completed) == "completed");
  assert(toString(DeploymentStatus.failed) == "failed");
  assert(toString(DeploymentStatus.rolledBack) == "rolledBack");

  assert(toStrings([
      DeploymentStatus.pending, DeploymentStatus.inProgress,
      DeploymentStatus.completed, DeploymentStatus.failed,
      DeploymentStatus.rolledBack
    ]) == ["pending", "inProgress", "completed", "failed", "rolledBack"]);
  assert(toDeploymentStatuses([
      "pending", "inProgress", "completed", "failed", "rolledBack"
    ]) == [
    DeploymentStatus.pending, DeploymentStatus.inProgress,
    DeploymentStatus.completed, DeploymentStatus.failed,
    DeploymentStatus.rolledBack
  ]);
}

// Deployment operation type
enum DeploymentOperation {
  deploy,
  undeploy,
  redeploy,
}

DeploymentOperation toDeploymentOperation(string value) {
  mixin(EnumSwitch("DeploymentOperation", "deploy"));
}

DeploymentOperation[] toDeploymentOperations(string[] values) {
  return values.map!(toDeploymentOperation).array;
}

string toString(DeploymentOperation value) {
  return value.to!string;
}

string[] toStrings(DeploymentOperation[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DeploymentOperation"));

  assert(toDeploymentOperation("deploy") == DeploymentOperation.deploy);
  assert(toDeploymentOperation("undeploy") == DeploymentOperation.undeploy);
  assert(toDeploymentOperation("redeploy") == DeploymentOperation.redeploy);

  assert(toDeploymentOperation("") == DeploymentOperation.deploy);
  assert(toDeploymentOperation("unknown") == DeploymentOperation.deploy);

  assert(toString(DeploymentOperation.deploy) == "deploy");
  assert(toString(DeploymentOperation.undeploy) == "undeploy");
  assert(toString(DeploymentOperation.redeploy) == "redeploy");

  assert(toStrings([
      DeploymentOperation.deploy, DeploymentOperation.undeploy,
      DeploymentOperation.redeploy
    ]) == ["deploy", "undeploy", "redeploy"]);
  assert(toDeploymentOperations(["deploy", "undeploy", "redeploy"]) == [
      DeploymentOperation.deploy, DeploymentOperation.undeploy,
      DeploymentOperation.redeploy
    ]);
}

// Service plan type
enum ServicePlan {
  appHost, // for deploying HTML5 apps
  appRuntime, // for accessing HTML5 apps at runtime
}

ServicePlan toServicePlan(string value) {
  mixin(EnumSwitch("ServicePlan", "appHost"));
}

ServicePlan[] toServicePlans(string[] values) {
  return values.map!(toServicePlan).array;
}

string toString(ServicePlan value) {
  return value.to!string;
}

string[] toStrings(ServicePlan[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ServicePlan"));

  assert(toServicePlan("appHost") == ServicePlan.appHost);
  assert(toServicePlan("appRuntime") == ServicePlan.appRuntime);

  assert(toServicePlan("") == ServicePlan.appHost);
  assert(toServicePlan("unknown") == ServicePlan.appHost);

  assert(toString(ServicePlan.appHost) == "appHost");
  assert(toString(ServicePlan.appRuntime) == "appRuntime");

  assert(toStrings([ServicePlan.appHost, ServicePlan.appRuntime]) == [
      "appHost", "appRuntime"
    ]);
  assert(toServicePlans(["appHost", "appRuntime"]) == [
      ServicePlan.appHost, ServicePlan.appRuntime
    ]);
}

// Service instance status
enum InstanceStatus : string {
  active = "active",
  suspended = "suspended",
  deleted_ = "deleted",
}

InstanceStatus toInstanceStatus(string value) {
  switch (value.toLower) {
  case "active":
    return InstanceStatus.active;
  case "suspended":
    return InstanceStatus.suspended;
  case "deleted":
    return InstanceStatus.deleted_;
  default:
    return InstanceStatus.active; // Default value for unknown strings is "active"
  }
}

InstanceStatus[] toInstanceStatuses(string[] values) {
  return values.map!(toInstanceStatus).array;
}

string toString(InstanceStatus value) {
  return cast(string)value;
}

string[] toStrings(InstanceStatus[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("InstanceStatus"));

  assert(toInstanceStatus("active") == InstanceStatus.active);
  assert(toInstanceStatus("suspended") == InstanceStatus.suspended);
  assert(toInstanceStatus("deleted") == InstanceStatus.deleted_);

  assert(toInstanceStatus("") == InstanceStatus.active);
  assert(toInstanceStatus("unknown") == InstanceStatus.active);

  assert(toString(InstanceStatus.active) == "active");
  assert(toString(InstanceStatus.suspended) == "suspended");
  assert(toString(InstanceStatus.deleted_) == "deleted");

  assert(toStrings([
      InstanceStatus.active, InstanceStatus.suspended, InstanceStatus.deleted_
    ]) == ["active", "suspended", "deleted"]);
  assert(toInstanceStatuses(["active", "suspended", "deleted"]) == [
      InstanceStatus.active, InstanceStatus.suspended, InstanceStatus.deleted_
    ]);
}

// Cache status
enum CacheStatus {
  valid,
  stale,
  expired,
}

CacheStatus toCacheStatus(string value) {
  mixin(EnumSwitch("CacheStatus", "valid"));
}

CacheStatus[] toCacheStatuses(string[] values) {
  return values.map!(toCacheStatus).array;
}

string toString(CacheStatus value) {
  return value.to!string;
}

string[] toStrings(CacheStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("CacheStatus"));

  assert(toCacheStatus("valid") == CacheStatus.valid);
  assert(toCacheStatus("stale") == CacheStatus.stale);
  assert(toCacheStatus("expired") == CacheStatus.expired);

  assert(toCacheStatus("") == CacheStatus.valid);
  assert(toCacheStatus("unknown") == CacheStatus.valid);

  assert(toString(CacheStatus.valid) == "valid");
  assert(toString(CacheStatus.stale) == "stale");
  assert(toString(CacheStatus.expired) == "expired");

  assert(toStrings([CacheStatus.valid, CacheStatus.stale, CacheStatus.expired]) == [
      "valid", "stale", "expired"
    ]);
  assert(toCacheStatuses(["valid", "stale", "expired"]) == [
      CacheStatus.valid, CacheStatus.stale, CacheStatus.expired
    ]);
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

FileCategory toFileCategory(string value) {
  mixin(EnumSwitch("FileCategory", "other"));
}

FileCategory[] toFileCategories(string[] values) {
  return values.map!(toFileCategory).array;
}

string toString(FileCategory value) {
  return value.to!string;
}

string[] toStrings(FileCategory[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("FileCategory"));

  assert(toFileCategory("html") == FileCategory.html);
  assert(toFileCategory("css") == FileCategory.css);
  assert(toFileCategory("javascript") == FileCategory.javascript);
  assert(toFileCategory("image") == FileCategory.image);
  assert(toFileCategory("font") == FileCategory.font);
  assert(toFileCategory("json") == FileCategory.json);
  assert(toFileCategory("xml") == FileCategory.xml);
  assert(toFileCategory("other") == FileCategory.other);

  assert(toFileCategory("") == FileCategory.other);
  assert(toFileCategory("unknown") == FileCategory.other);

  assert(toString(FileCategory.html) == "html");
  assert(toString(FileCategory.css) == "css");
  assert(toString(FileCategory.javascript) == "javascript");
  assert(toString(FileCategory.image) == "image");
  assert(toString(FileCategory.font) == "font");
  assert(toString(FileCategory.json) == "json");
  assert(toString(FileCategory.xml) == "xml");
  assert(toString(FileCategory.other) == "other");

  assert(toStrings([
      FileCategory.html, FileCategory.css, FileCategory.javascript,
      FileCategory.image, FileCategory.font, FileCategory.json, FileCategory.xml,
      FileCategory.other
    ]) == ["html", "css", "javascript", "image", "font", "json", "xml", "other"]);
  assert(toFileCategories([
      "html", "css", "javascript", "image", "font", "json", "xml", "other"
    ]) == [
    FileCategory.html, FileCategory.css, FileCategory.javascript,
    FileCategory.image, FileCategory.font, FileCategory.json, FileCategory.xml,
    FileCategory.other
  ]);
}

// Route status
enum RouteStatus {
  active,
  inactive,
}

RouteStatus toRouteStatus(string value) {
  mixin(EnumSwitch("RouteStatus", "active"));
}

RouteStatus[] toRouteStatuses(string[] values) {
  return values.map!(toRouteStatus).array;
}

string toString(RouteStatus value) {
  return value.to!string;
}

string[] toStrings(RouteStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("RouteStatus"));

  assert(toRouteStatus("active") == RouteStatus.active);
  assert(toRouteStatus("inactive") == RouteStatus.inactive);

  assert(toRouteStatus("") == RouteStatus.active);
  assert(toRouteStatus("unknown") == RouteStatus.active);

  assert(toString(RouteStatus.active) == "active");
  assert(toString(RouteStatus.inactive) == "inactive");

  assert(toStrings([RouteStatus.active, RouteStatus.inactive]) == [
      "active", "inactive"
    ]);
  assert(toRouteStatuses(["active", "inactive"]) == [
      RouteStatus.active, RouteStatus.inactive
    ]);
}
