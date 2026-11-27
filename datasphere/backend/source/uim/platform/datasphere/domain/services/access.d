/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Row level security: which rows of a view a user may read.
///
///   * a view that no enabled data access control protects is open to all
///   * otherwise a row is visible if at least one protecting control is
///     assigned to the user and its criteria match the row
module uim.platform.datasphere.domain.services.access;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct AccessDecision {
  bool allowed;
  bool protected_; /// at least one enabled control protects the view
  string[] matchedControls; /// controls that grant the row
  string reason;
}

/// True if the value satisfies the criteria of the control.
bool criteriaMatch(const DataAccessControl c, string value) {
  import std.uni : icmp;

  final switch (c.criteriaOperator) {
  case CriteriaOperator.equals:
  case CriteriaOperator.oneOf:
    return c.criteriaValues.any!(v => icmp(v.strip, value.strip) == 0);
  case CriteriaOperator.startsWith:
    return value.toLower.startsWith(c.criteriaValues[0].strip.toLower);
  case CriteriaOperator.between:
    auto low = c.criteriaValues[0].strip;
    auto high = c.criteriaValues[1].strip;
    try // numbers compare numerically, everything else as text
      return value.strip.to!double >= low.to!double && value.strip.to!double <= high.to!double;
    catch (Exception)
      return value.strip >= low && value.strip <= high;
  }
}

/// The value of a row column as text ("" + found = false if missing).
string rowValue(Json row, string column, out bool found) @trusted {
  import std.uni : icmp;

  found = false;
  if (row.type != Json.Type.object)
    return "";
  foreach (k, v; row.get!(Json[string]))
    if (icmp(k, column) == 0) {
      found = v.type != Json.Type.null_ && v.type != Json.Type.undefined;
      if (!found)
        return "";
      return v.type == Json.Type.string ? v.get!string : v.toString;
    }
  return "";
}

/// Decide whether the user may read the row of the view.
AccessDecision evaluateAccess(const DataAccessControl[] controls, string viewId, string user, Json row) {
  AccessDecision d;
  const(DataAccessControl)[] protecting;
  foreach (ref c; controls)
    if (c.protects(viewId))
      protecting ~= c;
  if (protecting.length == 0) {
    d.allowed = true;
    d.reason = "the view is not protected by a data access control";
    return d;
  }
  d.protected_ = true;
  auto assigned = protecting.filter!(c => c.assignedTo(user)).array;
  if (assigned.length == 0) {
    d.reason = "user '" ~ user ~ "' is assigned to none of the " ~ protecting.length.to!string ~ " protecting controls";
    return d;
  }
  foreach (c; assigned) {
    bool found;
    auto value = rowValue(row, c.criteriaColumn, found);
    if (found && criteriaMatch(c, value))
      d.matchedControls ~= c.id.value;
  }
  d.allowed = d.matchedControls.length > 0;
  d.reason = d.allowed ? "granted by " ~ d.matchedControls.join(", ")
    : "the row does not match the criteria of the controls assigned to '" ~ user ~ "'";
  return d;
}

///
unittest {
  DataAccessControl dach;
  dach.id = DataAccessControlId("dach");
  dach.criteriaColumn = "COUNTRY";
  dach.criteriaOperator = CriteriaOperator.oneOf;
  dach.criteriaValues = ["DE", "AT", "CH"];
  dach.targetViewIds = ["v"];
  dach.assignedUsers = ["ada"];
  DataAccessControl big;
  big.id = DataAccessControlId("big");
  big.criteriaColumn = "netAmount";
  big.criteriaOperator = CriteriaOperator.between;
  big.criteriaValues = ["1000", "99999"];
  big.targetViewIds = ["v"];
  big.assignedUsers = ["bob"];
  auto controls = [dach, big];
  auto de = Json(["country": Json("de"), "NETAMOUNT": Json(500)]);
  assert(evaluateAccess(controls, "w", "eve", de).allowed, "unprotected view");
  auto a = evaluateAccess(controls, "v", "ada", de);
  assert(a.allowed && a.protected_ && a.matchedControls == ["dach"]);
  assert(!evaluateAccess(controls, "v", "eve", de).allowed);
  assert(!evaluateAccess(controls, "v", "bob", de).allowed);
  assert(evaluateAccess(controls, "v", "bob", Json(["NETAMOUNT": Json(1250.5)])).allowed);
  assert(!evaluateAccess(controls, "v", "ada", Json(["COUNTRY": Json(null)])).allowed);
  DataAccessControl prefix;
  prefix.criteriaOperator = CriteriaOperator.startsWith;
  prefix.criteriaValues = ["EU-"];
  assert(criteriaMatch(prefix, "eu-west") && !criteriaMatch(prefix, "us-east"));
}
