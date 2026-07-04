/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.services.validators;

import uim.platform.snowflake;

mixin(ShowModule!());

@safe:
struct SnowflakeValidator {

  static string validateAccount(SnowflakeAccount a) {
    if (a.name.length == 0)   return "Account name is required";
    if (a.region.length == 0) return "Region is required";
    return null;
  }

  static string validateConnector(ZerocopyConnector c) {
    if (c.name.length == 0)           return "Connector name is required";
    if (c.accountId.value.length == 0) return "Account ID is required";
    return null;
  }

  static string validateWarehouse(SnowflakeWarehouse w) {
    if (w.name.length == 0)            return "Warehouse name is required";
    if (w.accountId.value.length == 0) return "Account ID is required";
    return null;
  }

  static string validateDatabase(SnowflakeDatabase db) {
    if (db.name.length == 0)            return "Database name is required";
    if (db.accountId.value.length == 0) return "Account ID is required";
    return null;
  }

  static string validateShare(DataProductShare s) {
    if (s.dataProductId.length == 0)   return "Data product ID is required";
    if (s.accountId.value.length == 0) return "Account ID is required";
    if (s.shareName.length == 0)       return "Share name is required";
    return null;
  }

  static string validateRole(SnowflakeRole r) {
    if (r.name.length == 0)            return "Role name is required";
    if (r.accountId.value.length == 0) return "Account ID is required";
    return null;
  }

  static string validateTenantUser(SnowflakeTenantUser u) {
    if (u.email.length == 0) return "Email is required";
    return null;
  }

  static string validateProvisioningRequest(ProvisioningRequest req) {
    if (req.accountName.length == 0)  return "Account name is required";
    if (req.region.length == 0)        return "Region is required";
    if (req.adminEmail.length == 0)    return "Admin email is required";
    if (req.adminFirstName.length == 0) return "Admin first name is required";
    if (req.adminLastName.length == 0)  return "Admin last name is required";
    return null;
  }
}
