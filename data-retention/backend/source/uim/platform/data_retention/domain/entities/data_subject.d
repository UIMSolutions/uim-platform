/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A data subject: the identified person (customer, employee, …) whose
/// personal data an application group processes for a business purpose.
///
/// Lifecycle:  active ─block─▶ blocked ─archive─▶ archived
///                │                │                 │
///                └──────────── markForDeletion ─────┘ ─destroy─▶ deleted
///
/// A legal hold (litigation, audit) stops marking and destruction. After
/// destruction the personal data (external id, name) is gone; the record
/// stays as a tombstone that proves when and how the data was destroyed.
module uim.platform.data_retention.domain.entities.data_subject;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DataSubject {
  mixin TenantEntity!DataSubjectId;

  string externalId; /// id of the person in the applications (e.g. customer number) — personal data
  string displayName; /// personal data
  ApplicationGroupId applicationGroupId;
  DataSubjectRoleId dataSubjectRoleId;
  BusinessPurposeId businessPurposeId;
  LegalGroundId legalGroundId; /// optional: only this legal ground applies
  LegalEntityId legalEntityId; /// optional
  long referenceDate; /// end of business (start of the residence period); 0 = business ongoing
  LifecycleStatus lifecycleStatus = LifecycleStatus.active;
  bool legalHold;
  string legalHoldReason;
  long blockedAt;
  long archivedAt;
  long markedForDeletionAt;
  long deletedAt;
  string deletionMethod; /// "delete" | "anonymize" once destroyed

  /// Derived from the rules on every read (never persisted).
  RetentionEvaluation evaluation;

  bool isDeleted() const {
    return lifecycleStatus == LifecycleStatus.deleted;
  }

  bool isBlocked() const {
    return lifecycleStatus.isBlockedOrLater;
  }

  /// Restrict processing (end of purpose, or on request).
  void block(long now) {
    requireNotDeleted("blocked");
    if (lifecycleStatus == LifecycleStatus.active) {
      lifecycleStatus = LifecycleStatus.blocked;
      blockedAt = now;
    }
  }

  /// Move blocked data to the archive (blocks first if needed).
  void archive(long now) {
    requireNotDeleted("archived");
    block(now);
    if (lifecycleStatus == LifecycleStatus.blocked) {
      lifecycleStatus = LifecycleStatus.archived;
      archivedAt = now;
    }
  }

  /// Retention expired: wait for destruction.
  void markForDeletion(long now) {
    requireNotDeleted("marked for deletion");
    requireNoLegalHold("marked for deletion");
    block(now);
    if (lifecycleStatus != LifecycleStatus.markedForDeletion) {
      lifecycleStatus = LifecycleStatus.markedForDeletion;
      markedForDeletionAt = now;
    }
  }

  /// Destroy the personal data (delete or anonymize).
  void destroy(long now, DeletionAction method) {
    requireNotDeleted("destroyed");
    requireNoLegalHold("destroyed");
    if (method == DeletionAction.block)
      throw DataRetentionException.invalid("Destruction needs the method 'delete' or 'anonymize'");
    if (blockedAt == 0)
      blockedAt = now;
    externalId = (method == DeletionAction.anonymize ? "anonymized-" : "deleted-") ~ id.value;
    displayName = "";
    legalHoldReason = "";
    lifecycleStatus = LifecycleStatus.deleted;
    deletedAt = now;
    deletionMethod = cast(string) method;
  }

  void setLegalHold(bool hold, string reason) {
    requireNotDeleted("put on legal hold");
    if (hold)
      requireText(reason, "The reason of a legal hold");
    legalHold = hold;
    legalHoldReason = hold ? reason.strip : "";
    if (hold && lifecycleStatus == LifecycleStatus.markedForDeletion)
      lifecycleStatus = archivedAt > 0 ? LifecycleStatus.archived : LifecycleStatus.blocked;
  }

  void validate() const {
    requireId(id.value, "Data subject ID");
    requireText(externalId, "External ID");
    requireMaxLength(externalId, 128, "External ID");
    requireMaxLength(displayName, 256, "Name");
    requireMaxLength(legalHoldReason, 500, "Legal hold reason");
    if (applicationGroupId.isNull)
      throw DataRetentionException.invalid("The application group of a data subject is required");
    if (businessPurposeId.isNull)
      throw DataRetentionException.invalid("The business purpose of a data subject is required");
  }

  protected void requireNotDeleted(string what) const {
    if (isDeleted)
      throw DataRetentionException.ruleViolation("Data subject '" ~ id.value ~ "' is already destroyed and cannot be " ~ what);
  }

  protected void requireNoLegalHold(string what) const {
    if (legalHold)
      throw DataRetentionException.ruleViolation("Data subject '" ~ id.value ~ "' is on legal hold (" ~ legalHoldReason
          ~ ") and cannot be " ~ what);
  }
}

///
unittest {
  DataSubject s;
  s.id = DataSubjectId("ds1");
  s.externalId = "C-1001";
  s.displayName = "Ada Lovelace";
  s.applicationGroupId = ApplicationGroupId("erp");
  s.businessPurposeId = BusinessPurposeId("sales");
  s.validate();

  s.archive(10);
  assert(s.lifecycleStatus == LifecycleStatus.archived && s.blockedAt == 10 && s.archivedAt == 10);
  s.setLegalHold(true, "Lawsuit 42");
  assert(failsWith(DrErrorKind.ruleViolation, () { s.markForDeletion(11); }));
  assert(failsWith(DrErrorKind.ruleViolation, () { s.destroy(11, DeletionAction.delete_); }));
  assert(failsWith(DrErrorKind.invalid, () { s.setLegalHold(true, ""); }));
  s.setLegalHold(false, "");
  s.markForDeletion(12);
  assert(s.lifecycleStatus == LifecycleStatus.markedForDeletion && s.markedForDeletionAt == 12);
  s.destroy(13, DeletionAction.anonymize);
  assert(s.isDeleted && s.externalId == "anonymized-ds1" && s.displayName == "" && s.deletionMethod == "anonymize");
  assert(failsWith(DrErrorKind.ruleViolation, () { s.block(14); }));

  DataSubject held;
  held.id = DataSubjectId("ds2");
  held.markForDeletion(1);
  held.setLegalHold(true, "Audit");
  assert(held.lifecycleStatus == LifecycleStatus.blocked);
}
