/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.global_account;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between GlobalAccount and its snapshot record.
struct GlobalAccountMapper {
  static Json toRecord(const GlobalAccount e) {
    auto r = baseRecord(e);
    r["displayName"] = e.displayName;
    r["description"] = e.description;
    r["contractNumber"] = e.contractNumber;
    r["licenseType"] = enumName(e.licenseType);
    r["status"] = enumName(e.status);
    r["region"] = e.region;
    r["costCenter"] = e.costCenter;
    r["companyName"] = e.companyName;
    r["contactEmail"] = e.contactEmail;
    r["maxSubaccounts"] = e.maxSubaccounts;
    r["maxDirectories"] = e.maxDirectories;
    r["enabledServices"] = listToJson(e.enabledServices);
    r["renewalDate"] = e.renewalDate;
    r["customProperties"] = propertiesToJson(e.customProperties);
    return r;
  }

  static GlobalAccount fromRecord(Json r) {
    GlobalAccount e;
    readBase(e, r);
    e.displayName = fieldString(r, "displayName");
    e.description = fieldString(r, "description");
    e.contractNumber = fieldString(r, "contractNumber");
    e.licenseType = fieldEnum!LicenseType(r, "licenseType", LicenseType.enterprise);
    e.status = fieldEnum!GlobalAccountStatus(r, "status", GlobalAccountStatus.active);
    e.region = fieldString(r, "region");
    e.costCenter = fieldString(r, "costCenter");
    e.companyName = fieldString(r, "companyName");
    e.contactEmail = fieldString(r, "contactEmail");
    e.maxSubaccounts = fieldInt(r, "maxSubaccounts", 100);
    e.maxDirectories = fieldInt(r, "maxDirectories", 20);
    e.enabledServices = fieldStrings(r, "enabledServices");
    e.renewalDate = fieldLong(r, "renewalDate");
    e.customProperties = fieldMap(r, "customProperties");
    return e;
  }
}
