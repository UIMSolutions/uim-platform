/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The rules of a tenant, loaded once per operation and cached per business
/// purpose: evaluating 10 000 data subjects of 5 purposes reads the rules 5
/// times, not 10 000 times.
module uim.platform.data_retention.application.services.rulebook;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class RuleBook {
  protected DrRepositories repos;
  protected TenantId t;
  protected BusinessPurpose[string] purposes;
  protected LegalGroundRules[][string] rules;

  this(DrRepositories repos, TenantId t) {
    this.repos = repos;
    this.t = t;
  }

  /// The purpose (cached); isNull if it does not exist.
  BusinessPurpose purposeOf(BusinessPurposeId id) {
    if (auto p = id.value in purposes)
      return *p;
    auto p = repos.businessPurposes.findById(t, id);
    purposes[id.value] = p;
    return p;
  }

  /// The active legal grounds of a purpose with their active rules.
  const(LegalGroundRules)[] rulesOf(BusinessPurposeId purpose) {
    if (auto r = purpose.value in rules)
      return *r;
    auto residence = repos.residenceRules.findByReference(t, "businessPurposeId", purpose.value);
    auto retention = repos.retentionRules.findByReference(t, "businessPurposeId", purpose.value);
    LegalGroundRules[] result;
    foreach (g; repos.legalGrounds.findByReference(t, "businessPurposeId", purpose.value)) {
      if (!g.active)
        continue;
      LegalGroundRules r;
      r.legalGroundId = g.id;
      r.legalGroundName = g.name;
      foreach (x; residence)
        if (x.active && x.legalGroundId == g.id) {
          r.hasResidence = true;
          r.residence = x.period;
        }
      foreach (x; retention)
        if (x.active && x.legalGroundId == g.id) {
          r.hasRetention = true;
          r.retention = x.period;
          r.actionOnExpiry = x.actionOnExpiry;
        }
      result ~= r;
    }
    rules[purpose.value] = result;
    return result;
  }

  /// Evaluate a reference date under a purpose (optionally one legal ground).
  RetentionEvaluation evaluate(BusinessPurposeId purpose, LegalGroundId ground, long referenceDate, long now) {
    RetentionEvaluation none;
    none.evaluated = true;
    none.evaluatedAt = now;
    auto p = purposeOf(purpose);
    if (p.isNull) {
      none.reason = "Business purpose '" ~ purpose.value ~ "' does not exist";
      return none;
    }
    if (!p.appliesRules) {
      none.reason = "Business purpose '" ~ p.name ~ "' is inactive";
      return none;
    }
    auto grounds = rulesOf(purpose);
    if (!ground.isNull) {
      grounds = grounds.filter!(g => g.legalGroundId == ground).array;
      if (grounds.length == 0) {
        none.reason = "Legal ground '" ~ ground.value ~ "' is not an active legal ground of '" ~ p.name ~ "'";
        return none;
      }
    }
    return evaluateRetention(referenceDate, grounds, now);
  }

  RetentionEvaluation evaluate(const DataSubject s, long now) {
    return evaluate(s.businessPurposeId, s.legalGroundId, s.referenceDate, now);
  }

  /// The subjects with their evaluation set.
  DataSubject[] evaluated(DataSubject[] subjects, long now) {
    foreach (ref s; subjects)
      s.evaluation = evaluate(s, now);
    return subjects;
  }
}
