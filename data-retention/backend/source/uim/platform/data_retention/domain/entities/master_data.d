/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Master data that business purposes and data subjects refer to:
///   ApplicationGroup  applications whose personal data is managed together
///   LegalEntity       company / organisation (jurisdiction of the rules)
///   DataSubjectRole   kind of person (customer, employee, vendor contact, …)
module uim.platform.data_retention.domain.entities.master_data;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ApplicationGroup {
  mixin TenantEntity!ApplicationGroupId;

  string name;
  string description;
  ApplicationGroupScope scope_ = ApplicationGroupScope.global;
  string[] applicationIds; /// technical ids of the applications (e.g. "S4-SD")
  bool active = true;

  void validate() const {
    requireId(id.value, "Application group ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
    foreach (a; applicationIds) {
      requireText(a, "Application ID");
      requireMaxLength(a, 128, "Application ID");
    }
  }
}

struct LegalEntity {
  mixin TenantEntity!LegalEntityId;

  string name;
  string description;
  string country; /// ISO 3166-1 alpha-2 (upper case)
  string region;
  bool active = true;

  void validate() const {
    requireId(id.value, "Legal entity ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
    requireMaxLength(region, 128, "Region");
    if (country.length && !isCountryCode(country))
      throw DataRetentionException.invalid("Country '" ~ country ~ "' must be an ISO 3166-1 alpha-2 code (e.g. DE)");
  }
}

struct DataSubjectRole {
  mixin TenantEntity!DataSubjectRoleId;

  string name;
  string description;
  bool active = true;

  void validate() const {
    requireId(id.value, "Data subject role ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
  }
}

/// Two upper case letters.
bool isCountryCode(string code) pure {
  return code.length == 2 && code.all!(c => c >= 'A' && c <= 'Z');
}

/// Trimmed, de-duplicated texts (order kept).
string[] uniqueTexts(const string[] values) {
  string[] result;
  foreach (v; values) {
    auto t = v.strip;
    if (t.length && !result.canFind(t))
      result ~= t;
  }
  return result;
}

///
unittest {
  ApplicationGroup g;
  g.id = ApplicationGroupId("erp");
  g.name = "ERP";
  g.validate();
  g.name = " ";
  assert(failsWith(DrErrorKind.invalid, () { g.validate(); }));

  LegalEntity e;
  e.id = LegalEntityId("de01");
  e.name = "UIM GmbH";
  e.country = "DE";
  e.validate();
  e.country = "Germany";
  assert(failsWith(DrErrorKind.invalid, () { e.validate(); }));
  assert(uniqueTexts([" a", "b", "a", ""]) == ["a", "b"]);
}
