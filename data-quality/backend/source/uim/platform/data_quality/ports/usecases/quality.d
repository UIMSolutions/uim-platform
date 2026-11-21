/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the quality analyses: validation, profiling,
/// duplicate detection and scorecards.
module uim.platform.data_quality.ports.usecases.quality;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IValidateData {
  /// Validate every record of a dataset; replaces its violations, updates
  /// the scorecard and takes a trend snapshot.
  ValidationRunResult validateDataset(TenantId t, DatasetId ds, UserId actor);
  /// Validate one record (unique rules against the rest of the dataset).
  DataRecord validateRecord(TenantId t, DatasetId ds, RecordId id, UserId actor);
  /// Stateless check of ad-hoc records against the rules of a dataset id
  /// (nothing is stored).
  InlineValidationResult[] validateInline(TenantId t, string datasetId, const InlineRecord[] records);
  Violation[] listViolations(TenantId t, DatasetId ds);
  Violation getViolation(TenantId t, DatasetId ds, ViolationId id);
}

interface IProfileData {
  /// Profile a dataset; replaces its column profiles and rescores it.
  ProfileRunResult profileDataset(TenantId t, DatasetId ds, UserId actor);
  /// Stateless profiling of ad-hoc records.
  ColumnStats[] profileInline(const InlineRecord[] records);
  ColumnProfile[] listColumnProfiles(TenantId t, DatasetId ds);
  ColumnProfile getColumnProfile(TenantId t, DatasetId ds, ColumnProfileId id);
}

interface IDetectDuplicates {
  /// Replaces the open match groups of the dataset (resolved ones stay).
  DetectResult detectDuplicates(DetectDuplicatesRequest r);
  /// Stateless detection over ad-hoc records.
  DetectedGroup[] detectInline(const InlineRecord[] records, const string[] matchFields, string strategy, double threshold);
  MatchGroup[] listMatchGroups(TenantId t, DatasetId ds);
  MatchGroup getMatchGroup(TenantId t, DatasetId ds, MatchGroupId id);
  /// Choose the golden record; merge fills its empty fields from the
  /// duplicates and deletes them.
  ResolveResult resolveMatchGroup(ResolveMatchGroupRequest r);
  void deleteMatchGroup(TenantId t, DatasetId ds, MatchGroupId id);
}

interface IScorecards {
  /// The scorecard from the current data (nothing is stored).
  Scorecard currentScorecard(TenantId t, DatasetId ds);
  /// Compute and store the current scorecard of a dataset.
  Scorecard computeScorecard(TenantId t, DatasetId ds, UserId actor);
  /// Store the current scorecard as a trend point (keeps maxSnapshots per dataset).
  QualitySnapshot takeSnapshot(TenantId t, DatasetId ds, UserId actor);
  QualitySnapshot[] listSnapshots(TenantId t, DatasetId ds);
  QualitySnapshot getSnapshot(TenantId t, DatasetId ds, SnapshotId id);
  void deleteSnapshot(TenantId t, DatasetId ds, SnapshotId id);
}
