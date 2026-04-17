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
  string visibility; // "private", "public"
  string serviceInstanceId;
  string createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("spaceId", spaceId)
      .set("name", name)
      .set("namespace", namespace_)
      .set("description", description)
      .set("visibility", visibility)
      .set("serviceInstanceId", serviceInstanceId)
      .set("createdBy", createdBy);

  }
}

struct UpdateHtmlAppRequest {
  string description;
  string visibility;
  string status;
  string modifiedBy;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("visibility", visibility)
      .set("status", status)
      .set("modifiedBy", modifiedBy);
  }
}

// AppVersion DTOs
struct CreateAppVersionRequest {
  TenantId tenantId;
  string appId;
  string versionCode;
  string description;
  string createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId)
      .set("versionCode", versionCode)
      .set("description", description)
      .set("createdBy", createdBy);
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
}

// AppFile DTOs
struct UploadAppFileRequest {
  TenantId tenantId;
  string versionId;
  string filePath; // relative path within app e.g. "index.html"
  string contentType; // MIME type
  string data; // base64-encoded file content
  string encoding; // e.g. "gzip", "br", "" for none
  string createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("versionId", versionId)
      .set("filePath", filePath)
      .set("contentType", contentType)
      .set("data", data)
      .set("encoding", encoding)
      .set("createdBy", createdBy);
  }
}

struct UpdateAppFileRequest {
  string data;
  string contentType;
  string encoding;

  Json toJson() const {
    return Json.emptyObject
      .set("data", data)
      .set("contentType", contentType)
      .set("encoding", encoding);
  }
}

// ServiceInstance DTOs
struct CreateServiceInstanceRequest {
  TenantId tenantId;
  string spaceId;
  string name;
  string plan; // "appHost", "appRuntime"
  string description;
  long sizeQuotaMb;
  string createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("spaceId", spaceId)
      .set("name", name)
      .set("plan", plan)
      .set("description", description)
      .set("sizeQuotaMb", sizeQuotaMb)
      .set("createdBy", createdBy);
  }
}

struct UpdateServiceInstanceRequest {
  string description;
  string status;
  long sizeQuotaMb;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("status", status)
      .set("sizeQuotaMb", sizeQuotaMb);
  }
}

// DeploymentRecord DTOs
struct CreateDeploymentRequest {
  TenantId tenantId;
  string appId;
  string versionId;
  string serviceInstanceId;
  string operation; // "deploy", "undeploy", "redeploy"
  string deployedBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId)
      .set("versionId", versionId)
      .set("serviceInstanceId", serviceInstanceId)
      .set("operation", operation)
      .set("deployedBy", deployedBy);
  }
}

// AppRoute DTOs
struct CreateAppRouteRequest {
  TenantId tenantId;
  string appId;
  string pathPrefix;
  string targetUrl;
  string description;
  string createdBy;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("appId", appId)
      .set("pathPrefix", pathPrefix)
      .set("targetUrl", targetUrl)
      .set("description", description)
      .set("createdBy", createdBy);
  }
}

struct UpdateAppRouteRequest {
  string pathPrefix;
  string targetUrl;
  string description;
  string status;

  Json toJson() const {
    return Json.emptyObject
      .set("pathPrefix", pathPrefix)
      .set("targetUrl", targetUrl)
      .set("description", description)
      .set("status", status);
  }
}

// ContentCache DTOs
struct CacheContentRequest {
  TenantId tenantId;
  string fileId;
  string filePath;
  string contentType;
  string data;
  long ttlSeconds;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("fileId", fileId)
      .set("filePath", filePath)
      .set("contentType", contentType)
      .set("data", data)
      .set("ttlSeconds", ttlSeconds);
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
}
