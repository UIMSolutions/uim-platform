/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.services.pattern_matcher;

import uim.platform.logging.domain.entities.alert_rule;
import uim.platform.logging.domain.entities.log_entry;
import uim.platform.logging.domain.types;

struct MatchResult {
  bool matched;
  string reason;
}

struct PatternMatcher {
  static MatchResult evaluate(const ref LogEntry entry, const ref AlertRule rule) {
    final switch (rule.condition) {
    case AlertCondition.contains:
      return evaluateContains(entry, rule);
    case AlertCondition.regex:
      return evaluateRegex(entry, rule);
    case AlertCondition.threshold:
      return MatchResult(false, "Threshold conditions evaluated separately");
    case AlertCondition.absence:
      return MatchResult(false, "Absence conditions evaluated separately");
    case AlertCondition.rateChange:
      return MatchResult(false, "Rate change conditions evaluated separately");
    }
  }

  private static MatchResult evaluateContains(const ref LogEntry entry, const ref AlertRule rule) {
    import std.string : indexOf;

    string fieldValue = getFieldValue(entry, rule.field);
    if (fieldValue.length == 0)
      return MatchResult(false, "Field value empty");

    if (fieldValue.indexOf(rule.pattern) >= 0) {
      return MatchResult(true, "Pattern '" ~ rule.pattern ~ "' found in field '" ~ rule.field ~ "'");
    }
    return MatchResult(false, "Pattern not found");
  }

  private static MatchResult evaluateRegex(const ref LogEntry entry, const ref AlertRule rule) {
    // Simplified regex support -- full implementation would use std.regex
    string fieldValue = getFieldValue(entry, rule.field);
    if (fieldValue.length == 0)
      return MatchResult(false, "Field value empty");

    import std.string : indexOf;

    if (fieldValue.indexOf(rule.pattern) >= 0)
      return MatchResult(true, "Pattern matched in field '" ~ rule.field ~ "'");
    return MatchResult(false, "Regex pattern not matched");
  }

  private static string getFieldValue(const ref LogEntry entry, string field) {
    switch (field) {
    case "message":
      return entry.message;
    case "source":
      return entry.source;
    case "componentName":
      return entry.componentName;
    case "resourceType":
      return entry.resourceType;
    default:
      return entry.message;
    }
  }
}
