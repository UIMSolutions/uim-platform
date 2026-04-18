/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.business_role;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

/// Business role for authorization in the ABAP environment.
struct BusinessRole {
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

  Json toJson() const {
    auto j = Json.emptyObject
      .set("id", id)
      .set("tenantId", tenantId)
      .set("systemInstanceId", systemInstanceId)
      .set("name", name)
      .set("description", description)
      .set("roleType", roleType.to!string)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);

    if (restrictionTypes.length > 0) {
      auto rt = Json.emptyArray;
      foreach (r; restrictionTypes)
        rt ~= Json(r);
      j["restrictionTypes"] = rt;
    }

    if (assignedCatalogs.length > 0) {
      auto cats = assignedCatalogs.map!(c => c.toJson)();
      j["assignedCatalogs"] = cats;
    }

    return j;
  }
}
