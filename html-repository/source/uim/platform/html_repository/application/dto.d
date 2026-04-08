/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.dto;

// HtmlApp DTOs
struct CreateHtmlAppRequest {
  TenantId tenantId;
  string spaceId;
  string name;
  string namespace_;
  string description;
  string visibility;    // "private", "public"
  string serviceInstanceId;
  string createdBy;
}

struct UpdateHtmlAppRequest {
  string description;
  string visibility;
  string status;
  string modifiedBy;
}

// AppVersion DTOs
struct CreateAppVersionRequest {
  TenantId tenantId;
  string appId;
  string versionCode;
  string description;
  string createdBy;
}

struct UpdateAppVersionRequest {
  string status;
  string description;
}

// AppFile DTOs
struct UploadAppFileRequest {
  TenantId tenantId;
  string versionId;
  string filePath;       // relative path within app e.g. "index.html"
  string contentType;    // MIME type
  string data;           // base64-encoded file content
  string encoding;       // e.g. "gzip", "br", "" for none
  string createdBy;
}

struct UpdateAppFileRequest {
  string data;
  string contentType;
  string encoding;
}

// ServiceInstance DTOs
struct CreateServiceInstanceRequest {
  TenantId tenantId;
  string spaceId;
  string name;
  string plan;           // "appHost", "appRuntime"
  string description;
  long sizeQuotaMb;
  string createdBy;
}

struct UpdateServiceInstanceRequest {
  string description;
  string status;
  long sizeQuotaMb;
}

// DeploymentRecord DTOs
struct CreateDeploymentRequest {
  TenantId tenantId;
  string appId;
  string versionId;
  string serviceInstanceId;
  string operation;      // "deploy", "undeploy", "redeploy"
  string deployedBy;
}

// AppRoute DTOs
struct CreateAppRouteRequest {
  TenantId tenantId;
  string appId;
  string pathPrefix;
  string targetUrl;
  string description;
  string createdBy;
}

struct UpdateAppRouteRequest {
  string pathPrefix;
  string targetUrl;
  string description;
  string status;
}

// ContentCache DTOs
struct CacheContentRequest {
  TenantId tenantId;
  string fileId;
  string filePath;
  string contentType;
  string data;
  long ttlSeconds;
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
}
