/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A request to block or erase the personal data of a data subject (e.g.
/// GDPR Art. 17 "right to erasure"). Retention obligations win: a deletion
/// before the end of retention is rejected and the subject is blocked
/// instead. The request holds no personal data itself.
module uim.platform.data_retention.domain.entities.deletion_request;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DeletionRequest {
  mixin TenantEntity!DeletionRequestId;

  DataSubjectId dataSubjectId;
  ApplicationGroupId applicationGroupId;
  DeletionAction action = DeletionAction.delete_;
  DeletionRequestStatus status = DeletionRequestStatus.pending;
  string reason;
  long processedAt;
  string resultMessage;
  long earliestDeletionAt; /// set when rejected because of a retention period

  bool isPending() const {
    return status == DeletionRequestStatus.pending;
  }

  void complete(long now, string message) {
    close(DeletionRequestStatus.completed, now, message);
  }

  void reject(long now, string message, long earliestDeletion = 0) {
    close(DeletionRequestStatus.rejected, now, message);
    earliestDeletionAt = earliestDeletion;
  }

  void fail(long now, string message) {
    close(DeletionRequestStatus.failed, now, message);
  }

  void cancel(long now) {
    close(DeletionRequestStatus.cancelled, now, "Cancelled");
  }

  void validate() const {
    requireId(id.value, "Deletion request ID");
    if (dataSubjectId.isNull)
      throw DataRetentionException.invalid("The data subject of a deletion request is required");
    requireMaxLength(reason, 1000, "Reason");
  }

  protected void close(DeletionRequestStatus to, long now, string message) {
    if (!isPending)
      throw DataRetentionException.ruleViolation("Deletion request '" ~ id.value ~ "' is already " ~ cast(string) status);
    status = to;
    processedAt = now;
    resultMessage = message;
  }
}

///
unittest {
  DeletionRequest r;
  r.id = DeletionRequestId("r1");
  r.dataSubjectId = DataSubjectId("ds1");
  r.validate();
  r.reject(5, "Retention until 2030", 99);
  assert(r.status == DeletionRequestStatus.rejected && r.earliestDeletionAt == 99 && r.processedAt == 5);
  assert(failsWith(DrErrorKind.ruleViolation, () { r.cancel(6); }));
}
