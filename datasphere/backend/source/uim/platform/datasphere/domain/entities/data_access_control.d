/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A data access control: row level security for views. Users assigned to
/// the control see the rows whose criteria column matches its values; a
/// view protected by at least one enabled control hides every other row.
module uim.platform.datasphere.domain.entities.data_access_control;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct DataAccessControl {
  mixin TenantEntity!DataAccessControlId;

  SpaceId spaceId;
  string name;
  string description;
  string criteriaColumn; /// column of the protected views (e.g. "COUNTRY")
  CriteriaOperator criteriaOperator = CriteriaOperator.equals;
  string[] criteriaValues;
  string[] targetViewIds; /// protected views
  string[] assignedUsers; /// user names that get the rows
  bool enabled = true;

  bool protects(string viewId) const {
    return enabled && targetViewIds.canFind(viewId);
  }

  bool assignedTo(string user) const {
    return assignedUsers.canFind(user);
  }

  void validate() const {
    requireId(id.value, "Data access control ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the data access control is required");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
    requireId(criteriaColumn, "Criteria column");
    if (criteriaValues.length == 0)
      throw DspException.invalid("At least one criteria value is required");
    if (criteriaOperator == CriteriaOperator.between && criteriaValues.length != 2)
      throw DspException.invalid("'between' needs exactly two values (low, high)");
    if ((criteriaOperator == CriteriaOperator.equals || criteriaOperator == CriteriaOperator.startsWith)
      && criteriaValues.length != 1)
      throw DspException.invalid("'" ~ cast(string) criteriaOperator ~ "' needs exactly one value (use oneOf for lists)");
    foreach (v; targetViewIds)
      requireId(v, "View");
    foreach (u; assignedUsers)
      requireId(u, "User");
  }
}

///
unittest {
  DataAccessControl d;
  d.id = DataAccessControlId("dach");
  d.spaceId = SpaceId("SALES");
  d.name = "DACH";
  d.criteriaColumn = "COUNTRY";
  d.criteriaValues = ["DE", "AT"];
  assert(failsWith(DspErrorKind.invalid, () { d.validate(); }), "equals takes one value");
  d.criteriaOperator = CriteriaOperator.oneOf;
  d.targetViewIds = ["v"];
  d.validate();
  assert(d.protects("v") && !d.protects("w"));
  d.enabled = false;
  assert(!d.protects("v"));
}
