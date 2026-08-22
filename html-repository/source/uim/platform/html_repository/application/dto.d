/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.dto;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
// HtmlApp DTOs
struct CreateHtmlAppRequest {
  TenantId tenantId;
  HtmlAppId appId;
  SpaceId spaceId;
  string name;
  string namespace_;
  string description;
  string visibility; // "private", "public"
  string serviceInstanceId;
  UserId createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId.value)
      .set("spaceId", spaceId.value)
      .set("name", name)
      .set("namespace", namespace_)
      .set("description", description)
      .set("visibility", visibility)
      .set("serviceInstanceId", serviceInstanceId)
      .set("createdBy", createdBy.value);
  }

  static CreateHtmlAppRequest fromJson(Json j) {
    auto req = CreateHtmlAppRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.spaceId = SpaceId(j["spaceId"].getString);
    req.name = j["name"].getString;
    req.namespace_ = j["namespace"].getString;
    req.description = j["description"].getString;
    req.visibility = j["visibility"].getString;
    req.serviceInstanceId = j["serviceInstanceId"].getString;
    req.createdBy = UserId(j["createdBy"].getString);
    return req;
  }
}

struct UpdateHtmlAppRequest {
  TenantId tenantId;
  HtmlAppId appId;
  SpaceId spaceId;
  string description;
  string visibility;
  string status;
  UserId updatedBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId.value)
      .set("spaceId", spaceId.value)
      .set("description", description)
      .set("visibility", visibility)
      .set("status", status)
      .set("updatedBy", updatedBy.value);
  }

  static UpdateHtmlAppRequest fromJson(Json j) {
    auto req = UpdateHtmlAppRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.spaceId = SpaceId(j["spaceId"].getString);
    req.description = j["description"].getString;
    req.visibility = j["visibility"].getString;
    req.status = j["status"].getString;
    req.updatedBy = UserId(j["updatedBy"].getString);
    return req;
  }
}

// AppVersion DTOs
struct CreateAppVersionRequest {
  TenantId tenantId;
  HtmlAppId appId;
  string versionCode;
  string description;
  UserId createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId.value)
      .set("versionCode", versionCode)
      .set("description", description)
      .set("createdBy", createdBy.value);
  }

  static CreateAppVersionRequest fromJson(Json j) {
    auto req = CreateAppVersionRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.versionCode = j["versionCode"].getString;
    req.description = j["description"].getString;
    req.createdBy = UserId(j["createdBy"].getString);
    return req;
  }
}

struct UpdateAppVersionRequest {
  string status;
  string description;

  Json toJson() const {
    return Json.emptyObject
      .set("status", status)
      .set("description", description);
  }

  static UpdateAppVersionRequest fromJson(Json j) {
    auto req = UpdateAppVersionRequest();
    req.status = j["status"].getString;
    req.description = j["description"].getString;
    return req;
  }
}
// AppFile DTOs
struct UploadAppFileRequest {
  TenantId tenantId;
  HtmlAppId appId;
  AppVersionId versionId;
  string filePath; // relative path within app e.g. "index.html"
  string contentType; // MIME type
  string content; // base64-encoded file content
  string encoding; // e.g. "gzip", "br", "" for none
  long sizeBytes;
  UserId createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId.value)
      .set("versionId", versionId.value)
      .set("filePath", filePath)
      .set("contentType", contentType)
      .set("content", content)
      .set("encoding", encoding)
      .set("sizeBytes", sizeBytes)
      .set("createdBy", createdBy.value);
  }

  static UploadAppFileRequest fromJson(Json j) {
    auto req = UploadAppFileRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.versionId = AppVersionId(j["versionId"].getString);
    req.filePath = j["filePath"].getString;
    req.contentType = j["contentType"].getString;
    req.content = j["content"].getString;
    req.encoding = j["encoding"].getString;
    req.sizeBytes = j["sizeBytes"].getInteger;
    req.createdBy = UserId(j["createdBy"].getString);
    return req;
  }
}

struct UpdateAppFileRequest {
  TenantId tenantId;
  AppVersionId versionId;
  AppFileId fileId;
  string content;
  string contentType;
  long sizeBytes;
  string encoding;

  Json toJson() const {
    return Json.emptyObject
      .set("contentType", contentType)
      .set("tenantId", tenantId.value)
      .set("versionId", versionId.value)
      .set("fileId", fileId.value)
      .set("encoding", encoding)
      .set("content", content)
      .set("sizeBytes", sizeBytes);
  }

  static UpdateAppFileRequest fromJson(Json j) {
    auto req = UpdateAppFileRequest();
    req.contentType = j["contentType"].getString;
    req.tenantId = TenantId(j["tenantId"].getString);
    req.versionId = AppVersionId(j["versionId"].getString);
    req.fileId = AppFileId(j["fileId"].getString);
    req.encoding = j["encoding"].getString;
    req.content = j["content"].getString;
    req.sizeBytes = j["sizeBytes"].getInteger;
    return req;
  }
}
// ServiceInstance DTOs
struct CreateServiceInstanceRequest {
  TenantId tenantId;
  ServiceInstanceId instanceId;
  SpaceId spaceId;
  string name;
  string plan; // "appHost", "appRuntime"
  string description;
  long sizeQuotaMb;
  UserId createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("spaceId", spaceId.value)
      .set("instanceId", instanceId.value)
      .set("name", name)
      .set("plan", plan)
      .set("description", description)
      .set("sizeQuotaMb", sizeQuotaMb)
      .set("createdBy", createdBy.value);
  }

  static CreateServiceInstanceRequest fromJson(Json j) {
    auto req = CreateServiceInstanceRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.spaceId = SpaceId(j["spaceId"].getString);
    req.instanceId = ServiceInstanceId(j["instanceId"].getString);
    req.name = j["name"].getString;
    req.plan = j["plan"].getString;
    req.description = j["description"].getString;
    req.sizeQuotaMb = j["sizeQuotaMb"].getInteger;
    req.createdBy = UserId(j["createdBy"].getString);
    return req;
  }
}

struct UpdateServiceInstanceRequest {
  TenantId tenantId;
  ServiceInstanceId instanceId;
  string name;
  SpaceId spaceId;
  string plan;
  string description;
  string status;
  long sizeQuotaMb;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("name", name)
      .set("spaceId", spaceId.value)
      .set("plan", plan)
      .set("tenantId", tenantId.value)
      .set("instanceId", instanceId.value)
      .set("status", status)
      .set("sizeQuotaMb", sizeQuotaMb);
  }

  static UpdateServiceInstanceRequest fromJson(Json j) {
    auto req = UpdateServiceInstanceRequest();
    req.description = j["description"].getString;
    req.name = j["name"].getString;
    req.spaceId = SpaceId(j["spaceId"].getString);
    req.plan = j["plan"].getString;
    req.tenantId = TenantId(j["tenantId"].getString);
    req.instanceId = ServiceInstanceId(j["instanceId"].getString);
    req.status = j["status"].getString;
    req.sizeQuotaMb = j["sizeQuotaMb"].getInteger;
    return req;
  }
}
// DeploymentRecord DTOs
struct CreateDeploymentRequest {
  TenantId tenantId;
  ServiceInstanceId instanceId;
  HtmlAppId appId;
  AppVersionId versionId;
  string operation; // "deploy", "undeploy", "redeploy"
  UserId deployedBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId.value)
      .set("versionId", versionId)
      .set("serviceInstanceId", instanceId.value)
      .set("operation", operation)
      .set("deployedBy", deployedBy.value);
  }

  static CreateDeploymentRequest fromJson(Json j) {
    auto req = CreateDeploymentRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.instanceId = ServiceInstanceId(j["serviceInstanceId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.versionId = AppVersionId(j["versionId"].getString);
    req.operation = j["operation"].getString;
    req.deployedBy = UserId(j["deployedBy"].getString);
    return req;
  }
}
// AppRoute DTOs
struct CreateAppRouteRequest {
  TenantId tenantId;
  AppRouteId routeId;
  HtmlAppId appId;
  string pathPrefix;
  string targetUrl;
  string description;
  UserId createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("routeId", routeId.value)
      .set("appId", appId.value)
      .set("pathPrefix", pathPrefix)
      .set("targetUrl", targetUrl)
      .set("description", description)
      .set("createdBy", createdBy.value);
  }

  static CreateAppRouteRequest fromJson(Json j) {
    auto req = CreateAppRouteRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.routeId = AppRouteId(j["routeId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.pathPrefix = j["pathPrefix"].getString;
    req.targetUrl = j["targetUrl"].getString;
    req.description = j["description"].getString;
    req.createdBy = UserId(j["createdBy"].getString);
    return req;
  }
}

struct UpdateAppRouteRequest {
    TenantId tenantId;
  AppRouteId routeId;
  HtmlAppId appId;
  string pathPrefix;
  string targetUrl;
  string description;
  string status;

  Json toJson() const {
    return Json.emptyObject
      .set("pathPrefix", pathPrefix)
      .set("tenantId", tenantId.value)
      .set("routeId", routeId.value)
      .set("appId", appId.value)
      .set("targetUrl", targetUrl)
      .set("description", description)
      .set("status", status);
  }

  static UpdateAppRouteRequest fromJson(Json j) {
    auto req = UpdateAppRouteRequest();
    req.pathPrefix = j["pathPrefix"].getString;
    req.tenantId = TenantId(j["tenantId"].getString);
    req.routeId = AppRouteId(j["routeId"].getString);
    req.appId = HtmlAppId(j["appId"].getString);
    req.targetUrl = j["targetUrl"].getString;
    req.description = j["description"].getString;
    req.status = j["status"].getString;
    return req;
  }
}
// ContentCache DTOs
struct CacheContentRequest {
  TenantId tenantId;
  AppFileId fileId;
  string filePath;
  string contentType;
  string content; // base64-encoded content
  long ttlSeconds;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("fileId", fileId.value)
      .set("filePath", filePath)
      .set("contentType", contentType)
      .set("content", content)
      .set("ttlSeconds", ttlSeconds);
  }

  static CacheContentRequest fromJson(Json j) {
    auto req = CacheContentRequest();
    req.tenantId = TenantId(j["tenantId"].getString);
    req.fileId = AppFileId(j["fileId"].getString);
    req.filePath = j["filePath"].getString;
    req.contentType = j["contentType"].getString;
    req.content = j["content"].getString;
    req.ttlSeconds = j["ttlSeconds"].getInteger;
    return req;
  }
}


// Overview
struct OverviewSummary {
  long totalApps;
  long totalVersions;
  long totalFiles;
  long totalServiceInstances;
  long totalDeployments;
  long totalRoutes;
  long totalCacheEntries;
  long totalStorageBytesUsed;

  Json toJson() const {
    return Json.emptyObject
      .set("totalApps", totalApps)
      .set("totalVersions", totalVersions)
      .set("totalFiles", totalFiles)
      .set("totalServiceInstances", totalServiceInstances)
      .set("totalDeployments", totalDeployments)
      .set("totalRoutes", totalRoutes)
      .set("totalCacheEntries", totalCacheEntries)
      .set("totalStorageBytesUsed", totalStorageBytesUsed);
  }

  static OverviewSummary fromJson(Json j) {
    auto summary = OverviewSummary();
    summary.totalApps = j["totalApps"].getInteger;
    summary.totalVersions = j["totalVersions"].getInteger;
    summary.totalFiles = j["totalFiles"].getInteger;
    summary.totalServiceInstances = j["totalServiceInstances"].getInteger;
    summary.totalDeployments = j["totalDeployments"].getInteger;
    summary.totalRoutes = j["totalRoutes"].getInteger;
    summary.totalCacheEntries = j["totalCacheEntries"].getInteger;
    summary.totalStorageBytesUsed = j["totalStorageBytesUsed"].getInteger;
    return summary;
  }
}
