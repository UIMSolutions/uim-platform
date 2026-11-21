/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: evaluates validation rules against records.
///
/// Empty values only violate "required" rules — every other rule type
/// skips them, so completeness and validity are measured separately.
/// Compiled regular expressions and parsed expressions are cached per
/// engine instance.
module uim.platform.data_quality.domain.services.validation_engine;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// One failed rule of a record.
struct RuleFinding {
  ValidationRuleId ruleId;
  string ruleName;
  RuleType ruleType;
  string fieldName;
  string fieldValue;
  RuleSeverity severity;
  string message;
  string suggestedValue;
}

/// The validation result of one record.
struct RecordCheck {
  int rulesChecked;
  RuleFinding[] findings;

  /// Passed rules / checked rules (%).
  double score() const {
    auto failed = findings.length > rulesChecked ? rulesChecked : findings.length;
    return percentage(rulesChecked - failed, rulesChecked);
  }

  /// Highest severity ("" without findings).
  string worstSeverity() const {
    string worst;
    int rank;
    foreach (f; findings)
      if (severityRank(f.severity) > rank) {
        rank = severityRank(f.severity);
        worst = cast(string) f.severity;
      }
    return worst;
  }
}

/// Does value exist in field of the reference dataset? (null = no reference data available)
alias ReferenceLookup = bool delegate(string dataset, string field, string value) @safe;

class ValidationEngine {
  protected Regex!char[string] regexCache;
  protected RuleExpression[string] expressionCache;

  /// Check one record against rules (already filtered to the applicable,
  /// active rules in priority order). Unique rules are counted, but checked
  /// by checkUniqueness.
  RecordCheck check(const ValidationRule[] rules, const FieldValue[] fields, scope ReferenceLookup lookup = null) {
    RecordCheck result;
    foreach (ref rule; rules) {
      if (rule.ruleType == RuleType.referenceData && lookup is null)
        continue;
      result.rulesChecked++;
      if (rule.ruleType == RuleType.unique)
        continue;
      RuleFinding finding;
      if (evaluateRule(rule, fields, lookup, finding))
        result.findings ~= finding;
    }
    return result;
  }

  /// Uniqueness over a dataset: findings per record index (every record
  /// sharing a non-empty value gets one finding per unique rule).
  RuleFinding[][] checkUniqueness(const ValidationRule[] rules, const FieldValue[][] records, const string[] recordIds) {
    auto result = new RuleFinding[][records.length];
    foreach (ref rule; rules) {
      if (rule.ruleType != RuleType.unique)
        continue;
      size_t[][string] byValue;
      foreach (i, fields; records) {
        auto v = fieldOf(fields, rule.fieldName).strip;
        if (v.length)
          byValue[rule.caseSensitive ? v : v.toLower] ~= i;
      }
      foreach (value, indexes; byValue) {
        if (indexes.length < 2)
          continue;
        foreach (i; indexes) {
          string[] others;
          foreach (j; indexes)
            if (j != i && others.length < 5)
              others ~= recordIds[j];
          result[i] ~= finding(rule, fieldOf(records[i], rule.fieldName),
            format("Value is not unique (also in %s%s)", others.join(", "), indexes.length - 1 > others.length ? ", …" : ""));
        }
      }
    }
    return result;
  }

  protected bool evaluateRule(const ref ValidationRule rule, const FieldValue[] fields, scope ReferenceLookup lookup,
    out RuleFinding result) {
    auto value = fieldOf(fields, rule.fieldName);
    auto present = value.strip.length > 0;

    final switch (rule.ruleType) {
    case RuleType.required:
      if (!present) {
        result = finding(rule, value, hasField(fields, rule.fieldName) ? "Value is required" : "Field is missing");
        return true;
      }
      return false;

    case RuleType.format:
      if (present && matchFirst(value, compiled(rule.pattern)).empty) {
        result = finding(rule, value, "Value does not match the pattern " ~ rule.pattern);
        return true;
      }
      return false;

    case RuleType.range:
      if (!present)
        return false;
      double v, lo, hi;
      if (!parseNumber(value, v)) {
        result = finding(rule, value, "Value is not a number");
        return true;
      }
      if (rule.minValue.length && parseNumber(rule.minValue, lo) && v < lo) {
        result = finding(rule, value, "Value is below the minimum " ~ rule.minValue, rule.minValue);
        return true;
      }
      if (rule.maxValue.length && parseNumber(rule.maxValue, hi) && v > hi) {
        result = finding(rule, value, "Value is above the maximum " ~ rule.maxValue, rule.maxValue);
        return true;
      }
      return false;

    case RuleType.length:
      if (!present)
        return false;
      auto n = charLength(value);
      double lo, hi;
      if (rule.minValue.length && parseNumber(rule.minValue, lo) && n < lo) {
        result = finding(rule, value, format("Value is too short (%d < %s characters)", n, rule.minValue));
        return true;
      }
      if (rule.maxValue.length && parseNumber(rule.maxValue, hi) && n > hi) {
        result = finding(rule, value, format("Value is too long (%d > %s characters)", n, rule.maxValue),
          prefixOf(value, cast(size_t) hi));
        return true;
      }
      return false;

    case RuleType.enumeration:
      if (!present)
        return false;
      foreach (a; rule.allowedValues)
        if (rule.caseSensitive ? a == value : icmpEq(a, value))
          return false;
      result = finding(rule, value, "Value is not one of " ~ clip(rule.allowedValues.join(", "), 80), closest(value, rule.allowedValues));
      return true;

    case RuleType.crossField:
      if (!present)
        return false;
      auto other = fieldOf(fields, rule.crossFieldName);
      if (!compareValues(value, rule.operator, other, rule.caseSensitive)) {
        result = finding(rule, value, format("Value must be %s field %s ('%s')", operatorText(rule.operator),
            rule.crossFieldName, clip(other)), rule.operator == "eq" ? other : "");
        return true;
      }
      return false;

    case RuleType.custom:
      if (!evaluate(parsed(rule.expression), fields)) {
        result = finding(rule, value, "Expression does not hold: " ~ rule.expression);
        return true;
      }
      return false;

    case RuleType.referenceData:
      if (!present)
        return false;
      if (!lookup(rule.referenceDataset, rule.referenceField, value.strip)) {
        result = finding(rule, value, format("Value is not in %s.%s", rule.referenceDataset, rule.referenceField));
        return true;
      }
      return false;

    case RuleType.unique:
      return false;
    }
  }

  protected Regex!char compiled(string pattern) @trusted {
    if (auto r = pattern in regexCache)
      return *r;
    if (regexCache.length > 512)
      regexCache = null;
    auto r = regex(pattern);
    regexCache[pattern] = r;
    return r;
  }

  protected RuleExpression parsed(string text) {
    if (auto e = text in expressionCache)
      return *e;
    if (expressionCache.length > 512)
      expressionCache = null;
    auto e = parseExpression(text);
    expressionCache[text] = e;
    return e;
  }

  protected static RuleFinding finding(const ref ValidationRule rule, string value, string message, string suggestion = "") {
    RuleFinding f;
    f.ruleId = rule.id;
    f.ruleName = rule.name;
    f.ruleType = rule.ruleType;
    f.fieldName = rule.fieldName.length ? rule.fieldName : "";
    f.fieldValue = value;
    f.severity = rule.severity;
    f.message = message;
    f.suggestedValue = suggestion;
    return f;
  }

  /// Allowed value that the value most likely meant ("" if none is close).
  protected static string closest(string value, const string[] allowed) {
    string best;
    double bestScore = 0.85;
    foreach (a; allowed) {
      if (icmpEq(a, value))
        return a;
      auto s = jaroWinkler(value.toLower, a.toLower);
      if (s > bestScore) {
        bestScore = s;
        best = a;
      }
    }
    return best;
  }

  protected static bool icmpEq(string a, string b) {
    import std.uni : icmp;

    return icmp(a, b) == 0;
  }

  protected static string prefixOf(string s, size_t chars) {
    string r;
    size_t n;
    foreach (dchar c; s) {
      if (n++ >= chars)
        break;
      r ~= c;
    }
    return r;
  }

  protected static string operatorText(string op) {
    switch (op) {
    case "ne":
      return "different from";
    case "lt":
      return "less than";
    case "le":
      return "at most";
    case "gt":
      return "greater than";
    case "ge":
      return "at least";
    default:
      return "equal to";
    }
  }
}

version (unittest) {
  ValidationRule testRule(string id, RuleType type, string field) {
    ValidationRule r;
    r.id = ValidationRuleId(id);
    r.name = id;
    r.ruleType = type;
    r.fieldName = field;
    r.status = RuleStatus.active;
    return r;
  }
}

///
unittest {
  auto engine = new ValidationEngine;
  auto email = testRule("email", RuleType.format, "email");
  email.pattern = `^[^@\s]+@[^@\s]+\.[a-z]{2,}$`;
  auto age = testRule("age", RuleType.range, "age");
  age.minValue = "0";
  age.maxValue = "120";
  auto country = testRule("country", RuleType.enumeration, "country");
  country.allowedValues = ["DE", "AT", "CH"];
  auto name = testRule("name", RuleType.required, "name");
  auto ref_ = testRule("iso", RuleType.referenceData, "country");
  ref_.referenceDataset = "countries";
  ref_.referenceField = "code";
  auto rules = [name, email, age, country, ref_];

  auto ok = engine.check(rules, [FieldValue("name", "Ada"), FieldValue("email", "ada@example.org"), FieldValue("age", "36"),
      FieldValue("country", "DE")], (string ds, string f, string v) => v == "DE");
  assert(ok.rulesChecked == 5 && ok.findings.length == 0 && ok.score == 100);

  auto bad = engine.check(rules, [FieldValue("email", "nope"), FieldValue("age", "130"), FieldValue("country", "de")]);
  assert(bad.rulesChecked == 4); // no reference data → iso not checked
  assert(bad.findings.length == 4 && bad.score == 0);
  assert(bad.findings[0].message == "Field is missing");
  assert(bad.findings[2].suggestedValue == "120" && bad.findings[3].suggestedValue == "DE");

  auto cross = testRule("pw", RuleType.crossField, "password2");
  cross.crossFieldName = "password";
  auto custom = testRule("adult", RuleType.custom, "");
  custom.expression = "country == DE => age >= 18";
  auto c = engine.check([cross, custom], [FieldValue("password", "a"), FieldValue("password2", "b"),
      FieldValue("country", "DE"), FieldValue("age", "17")]);
  assert(c.findings.length == 2 && c.findings[0].suggestedValue == "a" && c.worstSeverity == "error");

  auto unique = testRule("uid", RuleType.unique, "email");
  unique.caseSensitive = false;
  auto u = engine.checkUniqueness([unique], [[FieldValue("email", "a@x.de")], [FieldValue("email", "A@x.de")],
      [FieldValue("email", "b@x.de")], [FieldValue("email", "")]], ["r1", "r2", "r3", "r4"]);
  assert(u[0].length == 1 && u[1].length == 1 && u[2].length == 0 && u[3].length == 0);
  assert(u[0][0].message.canFind("r2"));
}
