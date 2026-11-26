/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Evaluation of subscription filters against a CloudEvent.
///   - inactive filters are ignored
///   - every include filter must match (AND)
///   - one matching exclude filter rejects the event
/// Comparisons are case sensitive; "oneOf" takes a comma separated list.
module uim.platform.application_events.domain.services.filters;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// True if the condition of the filter (ignoring include / exclude) holds.
bool conditionHolds(const EventFilter f, const CloudEvent e) {
  bool found;
  auto actual = e.attribute(f.attribute, found);
  final switch (f.operator_) {
  case EventFilterOperator.exists:
    return found;
  case EventFilterOperator.equals:
    return found && actual == f.value;
  case EventFilterOperator.notEquals:
    return !found || actual != f.value;
  case EventFilterOperator.contains:
    return found && actual.canFind(f.value);
  case EventFilterOperator.startsWith:
    return found && actual.startsWith(f.value);
  case EventFilterOperator.endsWith:
    return found && actual.endsWith(f.value);
  case EventFilterOperator.oneOf:
    return found && f.value.split(",").map!(v => v.strip).canFind(actual);
  }
}

struct FilterVerdict {
  bool passed = true;
  string reason; /// the filter that rejected the event
}

FilterVerdict evaluateFilters(const EventFilter[] filters, const CloudEvent e) {
  FilterVerdict v;
  foreach (f; filters) {
    if (!f.active)
      continue;
    auto holds = conditionHolds(f, e);
    if (f.filterType == FilterType.include && !holds) {
      v.passed = false;
      v.reason = "include filter '" ~ f.summary ~ "' did not match";
      return v;
    }
    if (f.filterType == FilterType.exclude && holds) {
      v.passed = false;
      v.reason = "exclude filter '" ~ f.summary ~ "' matched";
      return v;
    }
  }
  return v;
}

///
unittest {
  CloudEvent e;
  e.type = "a.b";
  e.source = "s4";
  e.data = Json(["country": Json("DE"), "amount": Json(1200)]);
  EventFilter f;
  f.attribute = "data.country";
  f.value = "DE";
  assert(conditionHolds(f, e));
  f.operator_ = EventFilterOperator.oneOf;
  f.value = "AT, CH";
  assert(!conditionHolds(f, e));
  f.value = "AT, DE";
  assert(conditionHolds(f, e));
  EventFilter amount;
  amount.attribute = "data.amount";
  amount.operator_ = EventFilterOperator.startsWith;
  amount.value = "12";
  EventFilter exclude;
  exclude.filterType = FilterType.exclude;
  exclude.attribute = "subject";
  exclude.operator_ = EventFilterOperator.exists;
  assert(evaluateFilters([f, amount, exclude], e).passed);
  e.subject = "BP 4711";
  auto v = evaluateFilters([f, amount, exclude], e);
  assert(!v.passed && v.reason.canFind("exclude"), v.reason);
  exclude.active = false;
  assert(evaluateFilters([f, amount, exclude], e).passed);
  amount.value = "99";
  assert(!evaluateFilters([f, amount], e).passed);
  EventFilter ne;
  ne.attribute = "data.missing";
  ne.operator_ = EventFilterOperator.notEquals;
  ne.value = "x";
  assert(conditionHolds(ne, e), "a missing attribute differs from every value");
}
