/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The small, safe expression language of custom validation rules.
///
///   expression := clause [ "=>" clause ]        (premise => conclusion)
///   clause     := comparison { "and" comparison }
///   comparison := field op [operand]
///   op         := == != < <= > >= contains startsWith endsWith matches in empty notEmpty
///   operand    := $otherField | 'text' | "text" | text   (in: comma separated list)
///
/// Examples:
///   "age >= 18"
///   "country == DE => postalCode matches ^[0-9]{5}$"
///   "status in active,blocked and validTo >= $validFrom"
///
/// Numbers compare numerically, everything else as text. A comparison of a
/// missing field reads it as "". With a premise, the rule only applies to
/// records for which the premise holds.
module uim.platform.data_quality.domain.services.expressions;

import std.uni : icmp;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum string[] expressionOperators = ["==", "!=", "<", "<=", ">", ">=", "contains", "startsWith", "endsWith", "matches",
    "in", "empty", "notEmpty"];

struct Comparison {
  string field;
  string op;
  string operand;
  bool operandIsField;
}

struct RuleExpression {
  Comparison[] premise; /// empty = always applies
  Comparison[] conclusion;
}

RuleExpression parseExpression(string text) @trusted {
  RuleExpression e;
  auto t = text.strip;
  auto arrow = t.indexOf("=>");
  if (arrow >= 0) {
    e.premise = parseClause(t[0 .. arrow]);
    e.conclusion = parseClause(t[arrow + 2 .. $]);
  } else
    e.conclusion = parseClause(t);
  return e;
}

private Comparison[] parseClause(string text) @trusted {
  Comparison[] result;
  auto rest = " " ~ text.strip ~ " ";
  while (true) {
    auto pos = indexOfWord(rest, "and");
    auto part = pos < 0 ? rest : rest[0 .. pos];
    result ~= parseComparison(part);
    if (pos < 0)
      break;
    rest = rest[pos + 4 .. $];
  }
  return result;
}

/// Position of " word " (case insensitive), or -1.
private ptrdiff_t indexOfWord(string s, string word) {
  import std.uni : toLower;

  auto lower = s.toLower;
  return lower.indexOf(" " ~ word ~ " ");
}

private Comparison parseComparison(string text) @trusted {
  auto t = text.strip;
  if (t.length == 0)
    throw DataQualityException.invalid("Empty comparison in expression");
  auto sp = t.indexOf(' ');
  // allow "a>=b" without blanks for symbolic operators
  if (sp < 0)
    foreach (op; ["<=", ">=", "==", "!=", "<", ">"])
      if (t.indexOf(op) > 0) {
        auto p = t.indexOf(op);
        return finish(t[0 .. p].strip, op, t[p + op.length .. $].strip);
      }
  if (sp < 0)
    throw DataQualityException.invalid("Comparison '" ~ t ~ "' needs an operator");
  auto field = t[0 .. sp].strip;
  auto rest = t[sp + 1 .. $].strip;
  auto sp2 = rest.indexOf(' ');
  auto op = sp2 < 0 ? rest : rest[0 .. sp2];
  auto operand = sp2 < 0 ? "" : rest[sp2 + 1 .. $].strip;
  return finish(field, op, operand);
}

private Comparison finish(string field, string op, string operand) @trusted {
  requireFieldName(field, "RuleExpression field");
  string canonical;
  foreach (o; expressionOperators)
    if (icmp(o, op) == 0)
      canonical = o;
  if (op == "=")
    canonical = "==";
  if (canonical.length == 0)
    throw DataQualityException.invalid("Unknown operator '" ~ op ~ "' (allowed: " ~ expressionOperators.join(" ") ~ ")");
  Comparison c;
  c.field = field;
  c.op = canonical;
  if (canonical == "empty" || canonical == "notEmpty") {
    if (operand.length)
      throw DataQualityException.invalid("Operator '" ~ canonical ~ "' takes no operand");
    return c;
  }
  if (operand.length == 0)
    throw DataQualityException.invalid("Operator '" ~ canonical ~ "' needs an operand");
  if (operand.length >= 2 && (operand[0] == '\'' || operand[0] == '"') && operand[$ - 1] == operand[0])
    c.operand = operand[1 .. $ - 1];
  else if (operand[0] == '$') {
    requireFieldName(operand[1 .. $], "RuleExpression field");
    c.operand = operand[1 .. $];
    c.operandIsField = true;
  } else
    c.operand = operand;
  if (canonical == "matches")
    try
      regex(c.operand);
    catch (Exception)
      throw DataQualityException.invalid("'" ~ c.operand ~ "' is not a valid regular expression");
  return c;
}

/// Evaluate one comparison against the fields of a record.
bool holds(const Comparison c, const FieldValue[] fields) @trusted {
  auto value = fieldOf(fields, c.field);
  auto other = c.operandIsField ? fieldOf(fields, c.operand) : c.operand;
  switch (c.op) {
  case "empty":
    return value.strip.length == 0;
  case "notEmpty":
    return value.strip.length > 0;
  case "contains":
    return value.indexOf(other) >= 0;
  case "startsWith":
    return value.startsWith(other);
  case "endsWith":
    return value.endsWith(other);
  case "matches":
    return !matchFirst(value, regex(other)).empty;
  case "in":
    return other.split(",").map!(s => s.strip).canFind(value.strip);
  default:
    return compareValues(value, c.op, other);
  }
}

/// True if the expression holds (or its premise does not).
bool evaluate(const RuleExpression e, const FieldValue[] fields) {
  foreach (p; e.premise)
    if (!holds(p, fields))
      return true;
  foreach (c; e.conclusion)
    if (!holds(c, fields))
      return false;
  return true;
}

///
unittest {
  auto rec = [FieldValue("country", "DE"), FieldValue("postalCode", "1234"), FieldValue("age", "17"),
    FieldValue("from", "2026-01-01"), FieldValue("to", "2025-12-31")];
  assert(!evaluate(parseExpression("age >= 18"), rec));
  assert(evaluate(parseExpression("age>=10"), rec));
  assert(!evaluate(parseExpression("country == DE => postalCode matches ^[0-9]{5}$"), rec));
  assert(evaluate(parseExpression("country == FR => postalCode matches ^[0-9]{5}$"), rec));
  assert(!evaluate(parseExpression("to >= $from"), rec));
  assert(evaluate(parseExpression("country in AT, CH, DE and age notEmpty"), rec));
  assert(evaluate(parseExpression("missing empty"), rec));
  assert(failsWith(DqErrorKind.invalid, () { parseExpression("age"); }));
  assert(failsWith(DqErrorKind.invalid, () { parseExpression("age like 3"); }));
  assert(failsWith(DqErrorKind.invalid, () { parseExpression("a matches (["); }));
}
