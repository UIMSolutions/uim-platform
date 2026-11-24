/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of the retention operations: end-of-purpose
/// checks, simulations, deletion requests and archiving jobs.
module uim.platform.data_retention.application.dtos.retention;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Check the end of purpose of the data subjects of one application group
/// (or of all groups): block what reached the end of purpose, mark what
/// reached the end of retention for destruction.
struct EndOfPurposeCheckRequest {
  TenantId tenantId;
  UserId actor;
  ApplicationGroupId applicationGroupId; /// empty = all groups
  bool simulate; /// only count, change nothing
}

struct EndOfPurposeCheckResult {
  string applicationGroupId;
  bool simulated;
  long checked;
  long noRule;
  long withinResidence;
  long withinRetention;
  long endOfRetention;
  long alreadyDeleted;
  long blocked; /// newly blocked (or: would be blocked)
  long markedForDeletion; /// newly marked (or: would be marked)
  long legalHolds; /// due for destruction but on legal hold
  long checkedAt;
  string[] blockedSubjects; /// ids (no personal data)
  string[] markedSubjects;
}

/// "What if": the dates for a business purpose and a reference date.
struct SimulationRequest {
  TenantId tenantId;
  BusinessPurposeId businessPurposeId;
  LegalGroundId legalGroundId; /// empty = all legal grounds of the purpose
  long referenceDate;
}

struct CreateDeletionRequestCommand {
  TenantId tenantId;
  UserId actor;
  string id; /// "" = generated
  DataSubjectId dataSubjectId;
  string action = "delete"; /// block | delete | anonymize
  string reason;
}

struct CreateArchivingJobCommand {
  TenantId tenantId;
  UserId actor;
  string id; /// "" = generated
  ApplicationGroupId applicationGroupId;
  string operation = "archive"; /// archive | destruct | archiveAndDestruct
  bool dryRun;
  long referenceBefore; /// std time; 0 = all data subjects
  long scheduledAt; /// std time; 0 = now
}

/// Outcome of a worker run (pending requests, due jobs).
struct RunSummary {
  long started;
  long completed;
  long rejected;
  long failed;

  void add(const RunSummary o) {
    started += o.started;
    completed += o.completed;
    rejected += o.rejected;
    failed += o.failed;
  }
}

struct SeedResult {
  long applicationGroups;
  long legalEntities;
  long dataSubjectRoles;
  long businessPurposes;
  long legalGrounds;
  long residenceRules;
  long retentionRules;
  long dataSubjects;
  long deletionRequests;
  long archivingJobs;
}
