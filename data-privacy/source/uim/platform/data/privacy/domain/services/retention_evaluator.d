/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.services.retention_evaluator;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.retention_rule;
import uim.platform.data.privacy.domain.ports.repositories.retention_rules;

/// Result of a retention evaluation.
struct RetentionEvaluation {
  bool isExpired;
  int maxRetentionDays;
  string applicableRule;
  string[] warnings;
}

/// Domain service — evaluates whether data retention has exceeded its allowed period.
class RetentionEvaluator {
  private RetentionRuleRepository ruleRepo;

  this(RetentionRuleRepository ruleRepo)
  {
    this.ruleRepo = ruleRepo;
  }

  /// Check if data of a given purpose has exceeded its retention period.
  RetentionEvaluation evaluate(TenantId tenantId, ProcessingPurpose purpose, long dataTimestamp)
  {
    // import std.datetime.systime : Clock;
    // import std.conv : to;

    RetentionEvaluation result;
    auto now = Clock.currStdTime();

    // Find rules for this purpose
    auto rules = ruleRepo.findByPurpose(tenantId, purpose);

    if (rules.length == 0)
    {
      // Try default rule
      auto defaultRule = ruleRepo.findDefault(tenantId);
      if (defaultRule !is null)
      {
        result.maxRetentionDays = defaultRule.retentionDays;
        result.applicableRule = defaultRule.name;
      }
      else
      {
        result.maxRetentionDays = 365; // fallback: 1 year
        result.applicableRule = "default (no rule configured)";
        result.warnings ~= "No retention rule found; using default 365 days";
      }
    }
    else
    {
      // Use the longest applicable retention rule
      int maxDays = 0;
      string ruleName;
      foreach (ref r; rules)
      {
        if (r.status == RetentionRuleStatus.active && r.retentionDays > maxDays)
        {
          maxDays = r.retentionDays;
          ruleName = r.name;
        }
      }
      if (maxDays > 0)
      {
        result.maxRetentionDays = maxDays;
        result.applicableRule = ruleName;
      }
      else
      {
        result.maxRetentionDays = 365;
        result.applicableRule = "default (all rules inactive)";
        result.warnings ~= "All matching rules inactive; using default 365 days";
      }
    }

    // Check if data is past retention
    long cutoff = now - (cast(long) result.maxRetentionDays * 24 * 60 * 60 * 10_000_000L);
    result.isExpired = dataTimestamp < cutoff;

    if (result.isExpired)
    {
      result.warnings ~= "Data has exceeded retention period of "
        ~ result.maxRetentionDays.to!string ~ " days";
    }

    return result;
  }
}
