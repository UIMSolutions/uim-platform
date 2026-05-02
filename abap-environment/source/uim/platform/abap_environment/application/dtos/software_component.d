module uim.platform.abap_environment.application.dtos.software_component;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

struct CreateSoftwareComponentRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string componentType; // "developmentPackage", "businessConfiguration", ...
  string repositoryUrl;
  string branch;
  string branchStrategy;
  string namespace;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("name", name)
      .set("description", description)
      .set("componentType", componentType)
      .set("repositoryUrl", repositoryUrl)
      .set("branch", branch)
      .set("branchStrategy", branchStrategy)
      .set("namespace", namespace);
  }
}

struct CloneSoftwareComponentRequest {
  string branch;
  string commitId;

  Json toJson() const {
    return Json.emptyObject
      .set("branch", branch)
      .set("commitId", commitId);
  }
}

struct PullSoftwareComponentRequest {
  string commitId;

  Json toJson() const {
    return Json.emptyObject
      .set("commitId", commitId);
  }
}