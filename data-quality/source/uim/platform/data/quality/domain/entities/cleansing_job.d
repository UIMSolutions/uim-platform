module uim.platform.data.quality.domain.entities.cleansing_job;

import uim.platform.data.quality.domain.types;

/// An asynchronous data cleansing job.
struct CleansingJob
{
  CleansingJobId id;
  TenantId tenantId;
  DatasetId datasetId;
  UserId requestedBy;
  JobStatus status = JobStatus.pending;
  RuleId[] ruleIds; // rules to apply

  long totalRecords;
  long processedRecords;
  long cleansedRecords; // records that were modified
  long errorRecords;

  string errorMessage;
  long createdAt;
  long startedAt;
  long completedAt;
}
