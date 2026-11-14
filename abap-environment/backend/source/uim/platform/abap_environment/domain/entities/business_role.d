/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.business_role;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A business role: business catalogs plus access restrictions.
struct BusinessRole {
  mixin TenantEntity!BusinessRoleId;

  SystemInstanceId systemInstanceId;
  string systemName;
  string name; /// e.g. "Z_BR_TRAVEL_PROCESSOR"
  string description;
  RoleType roleType = RoleType.unrestricted;
  string[] businessCatalogs; /// e.g. "SAP_CORE_BC_COM"
  string[] restrictionTypes;
}
