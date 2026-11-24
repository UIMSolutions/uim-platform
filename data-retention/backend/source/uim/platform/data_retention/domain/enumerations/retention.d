/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.data_retention.domain.enumerations.retention;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Reach of an application group.
enum ApplicationGroupScope : string {
  global = "global",
  regional = "regional",
  local = "local"
}

/// A business purpose applies its rules only while it is active.
enum BusinessPurposeStatus : string {
  inactive = "inactive", /// being defined; rules are not applied
  active = "active", /// rules apply to the data subjects of the purpose
  deprecated_ = "deprecated" /// no new data subjects; existing ones keep their rules
}

/// Legal basis of processing (GDPR Art. 6 (1) a–f).
enum LegalGroundType : string {
  consent = "consent",
  contract = "contract",
  legalObligation = "legalObligation",
  vitalInterest = "vitalInterest",
  publicInterest = "publicInterest",
  legitimateInterest = "legitimateInterest"
}

/// Unit of a residence or retention period.
enum PeriodUnit : string {
  days = "days",
  weeks = "weeks",
  months = "months",
  years = "years"
}

/// What happens to personal data at the end of retention (and what a
/// deletion request asks for).
enum DeletionAction : string {
  block = "block", /// restrict processing (deletion requests only)
  delete_ = "delete", /// remove the personal data, keep a tombstone for the audit
  anonymize = "anonymize" /// replace the personal data, keep the business data
}

/// Lifecycle of the personal data of a data subject.
enum LifecycleStatus : string {
  active = "active", /// in use for the business purpose (residence)
  blocked = "blocked", /// end of purpose reached: processing restricted, kept for legal reasons
  archived = "archived", /// blocked and moved to the archive
  markedForDeletion = "markedForDeletion", /// retention expired, waiting for destruction
  deleted = "deleted" /// personal data destroyed (deleted or anonymized)
}

/// Where a data subject stands relative to its rules.
enum RetentionPhase : string {
  noRule = "noRule", /// no active purpose, or no residence rule for the legal grounds
  withinResidence = "withinResidence", /// before the end of purpose
  withinRetention = "withinRetention", /// end of purpose passed: block, keep for the retention period
  endOfRetention = "endOfRetention" /// retention expired: destroy
}

enum DeletionRequestStatus : string {
  pending = "pending",
  completed = "completed",
  rejected = "rejected", /// retention or a legal hold forbids the deletion (the subject is blocked instead)
  failed = "failed",
  cancelled = "cancelled"
}

enum ArchivingOperation : string {
  archive = "archive", /// archive blocked data subjects
  destruct = "destruct", /// destroy data subjects whose retention expired
  archiveAndDestruct = "archiveAndDestruct"
}

enum JobStatus : string {
  scheduled = "scheduled",
  running = "running",
  completed = "completed",
  failed = "failed",
  cancelled = "cancelled"
}

/// Lifecycle order: blocked, archived, … are later than active.
bool isBlockedOrLater(LifecycleStatus s) pure {
  return s != LifecycleStatus.active;
}

///
unittest {
  assert(cast(string) DeletionAction.delete_ == "delete" && cast(string) BusinessPurposeStatus.deprecated_ == "deprecated");
  assert(isBlockedOrLater(LifecycleStatus.archived) && !isBlockedOrLater(LifecycleStatus.active));
}
