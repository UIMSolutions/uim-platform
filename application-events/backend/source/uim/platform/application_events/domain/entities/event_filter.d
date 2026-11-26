/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A filter rule of a subscription on a CloudEvents attribute ("type",
/// "source", "subject", …) or a member of the payload ("data.country").
module uim.platform.application_events.domain.entities.event_filter;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum string[] envelopeAttributes = ["id", "type", "source", "subject", "datacontenttype", "time", "specversion"];

/// True for envelope attributes and "data" / "data.<path>".
bool isValidFilterAttribute(string attribute) {
  auto a = attribute.strip;
  if (envelopeAttributes.canFind(a.toLower))
    return true;
  if (a == "data")
    return true;
  if (!a.startsWith("data.") || a.length > 200)
    return false;
  foreach (part; a.split(".")[1 .. $])
    if (part.length == 0 || !part.all!(c => (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')
        || c == '_' || c == '-'))
      return false;
  return true;
}

struct EventFilter {
  mixin TenantEntity!EventFilterId;

  EventSubscriptionId subscriptionId;
  FilterType filterType = FilterType.include;
  string attribute;
  EventFilterOperator operator_ = EventFilterOperator.equals;
  string value;
  bool active = true;
  string description;

  /// "data.country equals DE"
  string summary() const {
    auto text = (filterType == FilterType.exclude ? "not " : "") ~ attribute ~ " " ~ cast(string) operator_;
    return operator_ == EventFilterOperator.exists ? text : text ~ " " ~ value;
  }

  void validate() const {
    requireId(id.value, "Filter ID");
    if (subscriptionId.isNull)
      throw AehException.invalid("The subscription of the filter is required");
    if (!isValidFilterAttribute(attribute))
      throw AehException.invalid("Filter attribute '" ~ attribute ~ "' is invalid (" ~ envelopeAttributes.join(", ")
          ~ " or data.<member>[.<member>…])");
    if (operator_ != EventFilterOperator.exists)
      requireText(value, "Filter value");
    requireMaxLength(value, 1000, "Filter value");
    requireMaxLength(description, 1000, "Description");
  }
}

///
unittest {
  assert(isValidFilterAttribute("data.address.city") && isValidFilterAttribute("Subject") && !isValidFilterAttribute("data."));
  assert(!isValidFilterAttribute("payload") && !isValidFilterAttribute("data.a b"));
  EventFilter f;
  f.id = EventFilterId("f1");
  f.subscriptionId = EventSubscriptionId("s");
  f.attribute = "data.country";
  f.value = "DE";
  f.validate();
  assert(f.summary == "data.country equals DE");
  f.value = "";
  assert(failsWith(AehErrorKind.invalid, () { f.validate(); }));
  f.operator_ = EventFilterOperator.exists;
  f.filterType = FilterType.exclude;
  f.validate();
  assert(f.summary == "not data.country exists");
}
