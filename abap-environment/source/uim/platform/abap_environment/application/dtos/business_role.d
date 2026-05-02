module uim.platform.abap_environment.application.dtos.business_role;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

struct CreateBusinessRoleRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string roleType; // "unrestricted", "restricted", "custom"
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;

  Json toJson() const {
    return Json.emptyObject.set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("name", name)
      .set("description", description)
      .set("roleType", roleType)
      .set("restrictionTypes", restrictionTypes.array)
      .set("assignedCatalogs", assignedCatalogs.map!(c => c.toJson()).array);

  }
}

struct UpdateBusinessRoleRequest {
  string description;
  string roleType;
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;
}