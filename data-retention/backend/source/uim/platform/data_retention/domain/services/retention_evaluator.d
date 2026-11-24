/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Retention evaluation: where does a data subject stand?
///
///   end of purpose   = reference date + residence period
///   end of retention = end of purpose + retention period (0 without a retention rule)
///
/// A legal ground counts only if it has an active residence rule. When
/// several legal grounds apply, the one with the latest end of retention
/// governs (the longest legal obligation wins); ties go to the latest end
/// of purpose, then to the smaller legal ground id (deterministic).
module uim.platform.data_retention.domain.services.retention_evaluator;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// The active rules of one legal ground.
struct LegalGroundRules {
  LegalGroundId legalGroundId;
  string legalGroundName;
  bool hasResidence;
  RetentionPeriod residence;
  bool hasRetention;
  RetentionPeriod retention;
  DeletionAction actionOnExpiry = DeletionAction.delete_;
}

/// Result of an evaluation (derived, never stored).
struct RetentionEvaluation {
  bool evaluated; /// false: not computed yet
  RetentionPhase phase = RetentionPhase.noRule;
  LegalGroundId governingLegalGroundId;
  string governingLegalGroundName;
  RetentionPeriod residence;
  RetentionPeriod retention;
  long endOfPurpose; /// end of residence: block from here on
  long endOfRetention; /// destroy from here on
  DeletionAction actionOnExpiry = DeletionAction.delete_;
  string reason;
  long evaluatedAt;

  /// An active data subject past its end of purpose.
  bool dueForBlocking(LifecycleStatus status) const {
    return status == LifecycleStatus.active && phaseRank(phase) >= phaseRank(RetentionPhase.withinRetention);
  }

  /// A data subject whose retention expired and that is not yet destroyed.
  bool dueForDestruction(LifecycleStatus status, bool legalHold) const {
    return phase == RetentionPhase.endOfRetention && status != LifecycleStatus.deleted && !legalHold;
  }

  /// Days until (positive) or since (negative) the end of retention; 0 if unknown.
  long daysToEndOfRetention(long now) const {
    return endOfRetention > 0 ? (endOfRetention - now) / hnsecsPerDayL : 0;
  }
}

/// noRule < withinResidence < withinRetention < endOfRetention
int phaseRank(RetentionPhase phase) pure {
  final switch (phase) {
  case RetentionPhase.noRule:
    return 0;
  case RetentionPhase.withinResidence:
    return 1;
  case RetentionPhase.withinRetention:
    return 2;
  case RetentionPhase.endOfRetention:
    return 3;
  }
}

/// Evaluate a reference date against the rules of the applicable legal grounds.
RetentionEvaluation evaluateRetention(long referenceDate, const LegalGroundRules[] grounds, long now) {
  RetentionEvaluation e;
  e.evaluated = true;
  e.evaluatedAt = now;

  size_t bestIndex = size_t.max;
  long bestPurpose, bestRetention;
  foreach (i, ref g; grounds) {
    if (!g.hasResidence)
      continue;
    if (referenceDate <= 0) { // dates unknown: still pick the governing ground (longest rules)
      if (bestIndex == size_t.max || g.residence.approximateDays + g.retention.approximateDays
          > grounds[bestIndex].residence.approximateDays + grounds[bestIndex].retention.approximateDays)
        bestIndex = i;
      continue;
    }
    auto eop = g.residence.addTo(referenceDate);
    auto eor = g.hasRetention ? g.retention.addTo(eop) : eop;
    if (bestIndex == size_t.max || eor > bestRetention || (eor == bestRetention && (eop > bestPurpose
        || (eop == bestPurpose && g.legalGroundId.value < grounds[bestIndex].legalGroundId.value)))) {
      bestIndex = i;
      bestPurpose = eop;
      bestRetention = eor;
    }
  }

  if (bestIndex == size_t.max) {
    e.phase = RetentionPhase.noRule;
    e.reason = grounds.length == 0 ? "No active legal ground applies" : "No legal ground has an active residence rule";
    return e;
  }

  const best = grounds[bestIndex];
  e.governingLegalGroundId = best.legalGroundId;
  e.governingLegalGroundName = best.legalGroundName;
  e.residence = best.residence;
  e.retention = best.hasRetention ? best.retention : RetentionPeriod(0, PeriodUnit.days);
  e.actionOnExpiry = best.actionOnExpiry;
  auto rules = format("residence %s, retention %s", e.residence.text, e.retention.text);
  auto ground = best.legalGroundName.length ? best.legalGroundName : best.legalGroundId.value;

  if (referenceDate <= 0) {
    e.phase = RetentionPhase.withinResidence;
    e.reason = "No reference date: the business is not completed (" ~ ground ~ ": " ~ rules ~ ")";
    return e;
  }

  e.endOfPurpose = bestPurpose;
  e.endOfRetention = bestRetention;
  if (now < bestPurpose) {
    e.phase = RetentionPhase.withinResidence;
    e.reason = "In use until the end of purpose on " ~ isoDateText(bestPurpose);
  } else if (now < bestRetention) {
    e.phase = RetentionPhase.withinRetention;
    e.reason = "Blocked; retention until " ~ isoDateText(bestRetention);
  } else {
    e.phase = RetentionPhase.endOfRetention;
    e.reason = "Retention expired on " ~ isoDateText(bestRetention) ~ ": " ~ cast(string) best.actionOnExpiry;
  }
  e.reason ~= " (" ~ ground ~ ": " ~ rules ~ ")";
  return e;
}

///
unittest {
  auto ref_ = parseIsoTime("2020-01-15");
  auto contract = LegalGroundRules(LegalGroundId("contract"), "Contract", true, RetentionPeriod(1, PeriodUnit.years), true,
    RetentionPeriod(3, PeriodUnit.years));
  auto tax = LegalGroundRules(LegalGroundId("tax"), "Tax", true, RetentionPeriod(1, PeriodUnit.years), true,
    RetentionPeriod(10, PeriodUnit.years), DeletionAction.anonymize);
  auto noResidence = LegalGroundRules(LegalGroundId("x"), "X", false);

  // the longest retention governs
  auto e = evaluateRetention(ref_, [contract, tax], parseIsoTime("2022-06-01"));
  assert(e.phase == RetentionPhase.withinRetention && e.governingLegalGroundId.value == "tax", e.to!string);
  assert(isoDateText(e.endOfPurpose) == "2021-01-15" && isoDateText(e.endOfRetention) == "2031-01-15");
  assert(e.actionOnExpiry == DeletionAction.anonymize && e.dueForBlocking(LifecycleStatus.active));
  assert(!e.dueForBlocking(LifecycleStatus.blocked) && !e.dueForDestruction(LifecycleStatus.blocked, false));

  assert(evaluateRetention(ref_, [contract], parseIsoTime("2020-06-01")).phase == RetentionPhase.withinResidence);
  auto expired = evaluateRetention(ref_, [contract], parseIsoTime("2024-01-15"));
  assert(expired.phase == RetentionPhase.endOfRetention && expired.dueForDestruction(LifecycleStatus.archived, false));
  assert(!expired.dueForDestruction(LifecycleStatus.archived, true) && expired.daysToEndOfRetention(parseIsoTime("2024-01-15")) == 0);

  // no residence rule → noRule; no reference date → open-ended residence
  assert(evaluateRetention(ref_, [noResidence], 0).phase == RetentionPhase.noRule);
  assert(evaluateRetention(ref_, [], 0).reason == "No active legal ground applies");
  auto open = evaluateRetention(0, [contract, tax], parseIsoTime("2050-01-01"));
  assert(open.phase == RetentionPhase.withinResidence && open.endOfRetention == 0 && open.governingLegalGroundId.value == "tax");

  // without a retention rule the data is destroyed at the end of purpose
  auto consent = LegalGroundRules(LegalGroundId("consent"), "Consent", true, RetentionPeriod(2, PeriodUnit.years));
  auto c = evaluateRetention(ref_, [consent], parseIsoTime("2022-01-15"));
  assert(c.phase == RetentionPhase.endOfRetention && c.endOfPurpose == c.endOfRetention);
}
