/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A saved inbox filter. Criteria are written as "type=value" pairs separated
/// by commas, e.g. "status=open,priority=high,priority=veryHigh,assignee=$me".
/// Equal types are OR-ed, different types AND-ed; the filter translates into
/// an OData $filter expression that the Fiori app and the CLI apply directly.
module uim.platform.task_center.domain.entities.user_task_filter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Placeholder for the calling user in filter values.
enum string currentUserPlaceholder = "$me";

struct FilterCriterion {
  FilterCriterionType criterionType = FilterCriterionType.status;
  string value;
}

struct UserTaskFilter {
  mixin TenantEntity!UserTaskFilterId;

  string userId; /// owner
  string name;
  string description;
  FilterCriterion[] criteria;
  bool isDefault; /// at most one default per user

  void validate() const {
    requireText(userId, "userId");
    requireText(name, "Filter name");
    foreach (c; criteria) {
      requireText(c.value, "Value of criterion '" ~ cast(string) c.criterionType ~ "'");
      if (c.criterionType == FilterCriterionType.status)
        parseDomainEnum!TaskStatus(c.value, "status criterion");
      if (c.criterionType == FilterCriterionType.priority)
        parseDomainEnum!TaskPriority(c.value, "priority criterion");
      if (c.criterionType == FilterCriterionType.category)
        parseDomainEnum!TaskCategory(c.value, "category criterion");
      if (c.criterionType == FilterCriterionType.dueDate)
        requireOptionalDate(c.value, "dueDate criterion");
    }
  }

  /// OData $filter over Tasks ("" = no restriction).
  string toODataFilter(string currentUser) const {
    string[][string] groups;
    string[] order;
    foreach (c; criteria) {
      auto property = taskPropertyOf(c.criterionType);
      auto value = c.value == currentUserPlaceholder ? currentUser : c.value;
      auto literal = "'" ~ value.replace("'", "''") ~ "'";
      auto term = c.criterionType == FilterCriterionType.dueDate ? property ~ " le " ~ literal : property ~ " eq " ~ literal;
      if (property !in groups)
        order ~= property;
      groups[property] ~= term;
    }
    string[] parts;
    foreach (p; order)
      parts ~= groups[p].length == 1 ? groups[p][0] : "(" ~ groups[p].join(" or ") ~ ")";
    return parts.join(" and ");
  }
}

/// Task property a criterion filters on.
string taskPropertyOf(FilterCriterionType t) pure nothrow {
  final switch (t) {
  case FilterCriterionType.status:
    return "status";
  case FilterCriterionType.priority:
    return "priority";
  case FilterCriterionType.provider:
    return "providerId";
  case FilterCriterionType.category:
    return "category";
  case FilterCriterionType.dueDate:
    return "dueDate";
  case FilterCriterionType.assignee:
    return "assignee";
  case FilterCriterionType.creator:
    return "creator";
  case FilterCriterionType.taskDefinition:
    return "definitionId";
  }
}

/// "status=open, priority=high" → criteria. Throws invalid.
FilterCriterion[] parseCriteria(string text) {
  FilterCriterion[] result;
  foreach (part; text.split(",")) {
    auto p = part.strip;
    if (p.length == 0)
      continue;
    auto eq = p.indexOf('=');
    if (eq <= 0)
      throw TaskCenterException.invalid("Criterion '" ~ p ~ "' must have the form type=value");
    result ~= FilterCriterion(parseDomainEnum!FilterCriterionType(p[0 .. eq], "criterion type"), p[eq + 1 .. $].strip);
  }
  return result;
}

/// criteria → "status=open,priority=high"
string formatCriteria(const FilterCriterion[] criteria) {
  return criteria.map!(c => cast(string) c.criterionType ~ "=" ~ c.value).join(",");
}

///
unittest {
  UserTaskFilter f;
  f.userId = "anna";
  f.name = "Urgent approvals";
  f.criteria = parseCriteria("status=open, priority=high,priority=veryHigh , assignee=$me, category=approval");
  f.validate();
  assert(formatCriteria(f.criteria) == "status=open,priority=high,priority=veryHigh,assignee=$me,category=approval");
  assert(f.toODataFilter("anna") == "status eq 'open' and (priority eq 'high' or priority eq 'veryHigh') and assignee eq 'anna' and category eq 'approval'");
  f.criteria = parseCriteria("creator=O'Brien,dueDate=2026-12-31");
  assert(f.toODataFilter("x") == "creator eq 'O''Brien' and dueDate le '2026-12-31'");
  assert(failsWith(TaskCenterErrorKind.invalid, () { parseCriteria("colour=red"); }));
  assert(failsWith(TaskCenterErrorKind.invalid, () { parseCriteria("open"); }));
  f.criteria = parseCriteria("status=sleeping");
  assert(failsWith(TaskCenterErrorKind.invalid, () { f.validate(); }));
}
