/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value object: one attribute condition of a policy, e.g. `country eq US`.
///
/// Conditions are written (CLI, GUI, Fiori, OData) as a compact text:
///   "country eq US; department in Sales,Support; level ge 3"
/// Values may be quoted with ' or " if they contain ';'.
module uim.platform.authorization.domain.types.condition;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct PolicyCondition {
  string attribute;
  ConditionOperator operator = ConditionOperator.eq;
  string value;

  /// "country eq US"
  string toText() const {
    if (operator == ConditionOperator.exists)
      return attribute ~ " exists";
    auto v = value.canFind(';') || value.canFind(' ') ? "'" ~ value ~ "'" : value;
    return attribute ~ " " ~ cast(string) operator ~ " " ~ v;
  }

  Json toJson() const {
    return Json.emptyObject
      .set("attribute", attribute)
      .set("operator", cast(string) operator)
      .set("value", value);
  }
}

/// Parse one condition ("attr op value" or "attr exists").
PolicyCondition parseCondition(string text) {
  auto t = text.strip;
  auto firstSpace = t.indexOf(' ');
  if (firstSpace <= 0)
    throw AuthorizationException.invalid("Invalid condition '" ~ text ~ "' (expected: <attribute> <operator> <value>)");
  PolicyCondition c;
  c.attribute = t[0 .. firstSpace].strip;
  auto rest = t[firstSpace + 1 .. $].strip;
  auto secondSpace = rest.indexOf(' ');
  auto op = secondSpace < 0 ? rest : rest[0 .. secondSpace];
  c.operator = parseOperator(op);
  if (c.operator == ConditionOperator.exists) {
    if (secondSpace >= 0)
      throw AuthorizationException.invalid("Operator 'exists' takes no value: '" ~ text ~ "'");
    return c;
  }
  if (secondSpace < 0)
    throw AuthorizationException.invalid("Condition '" ~ text ~ "' has no value");
  auto value = rest[secondSpace + 1 .. $].strip;
  if (value.length >= 2 && (value[0] == '\'' || value[0] == '"') && value[$ - 1] == value[0])
    value = value[1 .. $ - 1];
  c.value = value;
  return c;
}

/// Parse a ';' separated list of conditions (empty text → no conditions).
PolicyCondition[] parseConditions(string text) {
  PolicyCondition[] result;
  string current;
  char quote = 0;
  foreach (ch; text) {
    if (quote != 0) {
      if (ch == quote)
        quote = 0;
      current ~= ch;
    } else if (ch == '\'' || ch == '"') {
      quote = ch;
      current ~= ch;
    } else if (ch == ';') {
      if (current.strip.length > 0)
        result ~= parseCondition(current);
      current = "";
    } else
      current ~= ch;
  }
  if (quote != 0)
    throw AuthorizationException.invalid("Unterminated quote in conditions '" ~ text ~ "'");
  if (current.strip.length > 0)
    result ~= parseCondition(current);
  return result;
}

/// Render conditions as text (inverse of parseConditions).
string conditionsText(const PolicyCondition[] conditions) {
  return conditions.map!(c => c.toText).join("; ");
}

///
unittest {
  mixin(ShowTest!("PolicyCondition"));

  auto cs = parseConditions("country eq US; department in Sales,Support;  level ge 3 ; email exists");
  assert(cs.length == 4);
  assert(cs[0].attribute == "country" && cs[0].operator == ConditionOperator.eq && cs[0].value == "US");
  assert(cs[1].operator == ConditionOperator.in_ && cs[1].value == "Sales,Support");
  assert(cs[2].operator == ConditionOperator.ge && cs[2].value == "3");
  assert(cs[3].operator == ConditionOperator.exists);
  assert(parseConditions("") == null);
  assert(parseConditions("note eq 'a; b'")[0].value == "a; b");
  assert(parseConditions("region == EU")[0].operator == ConditionOperator.eq); // legacy alias
  assert(conditionsText(cs) == "country eq US; department in Sales,Support; level ge 3; email exists");
  assert(failsWith(AuthorizationErrorKind.invalid, () { parseConditions("country"); }));
  assert(failsWith(AuthorizationErrorKind.invalid, () { parseConditions("country like US"); }));
}
