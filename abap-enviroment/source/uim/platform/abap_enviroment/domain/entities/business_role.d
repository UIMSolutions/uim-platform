module uim.platform.abap_enviroment.domain.entities.business_role;

import uim.platform.abap_enviroment.domain.types;

/// Catalog assignment attached to a role.
struct CatalogAssignment
{
  string catalogId;
  string catalogName;
}

/// Business role for authorization in the ABAP environment.
struct BusinessRole
{
  BusinessRoleId id;
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  RoleType roleType = RoleType.unrestricted;

  /// Access restrictions
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;

  /// Metadata
  string createdBy;
  long createdAt;
  long updatedAt;
}
