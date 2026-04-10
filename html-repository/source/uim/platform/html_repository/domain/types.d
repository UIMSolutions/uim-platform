/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.types;

// ID aliases
struct HtmlAppId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AppVersionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AppFileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DeploymentRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AppRouteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentCacheId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TenantId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SpaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

// Application visibility
enum AppVisibility {
  private_,   // accessible only within same space
  public_,    // shared across spaces
}

// Application status
enum AppStatus {
  active,
  inactive,
  deleted_,
}

// Version status
enum VersionStatus {
  active,
  superseded,
  archived,
}

// Deployment status
enum DeploymentStatus {
  pending,
  inProgress,
  completed,
  failed,
  rolledBack,
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
