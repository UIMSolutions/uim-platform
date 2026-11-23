/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.data_quality.ports.repositories.repositories;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IDatasetRepository : IDqTenantRepository!(Dataset, DatasetId) {
}

interface IRecordRepository : IDqScopedRepository!(DataRecord, RecordId) {
}

interface IValidationRuleRepository : IDqTenantRepository!(ValidationRule, ValidationRuleId) {
}

interface IViolationRepository : IDqScopedRepository!(Violation, ViolationId) {
  Violation[] findByRecord(TenantId t, DatasetId ds, RecordId record);
  size_t removeByRecord(TenantId t, DatasetId ds, RecordId record);
}

interface ICleansingRuleRepository : IDqTenantRepository!(CleansingRule, CleansingRuleId) {
}

interface ICleansingJobRepository : IDqScopedRepository!(CleansingJob, CleansingJobId) {
  /// Jobs of every dataset in a status (creation order).
  CleansingJob[] findByStatus(TenantId t, JobStatus status);
}

interface IMatchGroupRepository : IDqScopedRepository!(MatchGroup, MatchGroupId) {
}

interface IColumnProfileRepository : IDqScopedRepository!(ColumnProfile, ColumnProfileId) {
}

interface IAddressRepository : IDqTenantRepository!(PostalAddress, AddressId) {
}

interface ISnapshotRepository : IDqScopedRepository!(QualitySnapshot, SnapshotId) {
}

interface IUserAccountRepository : IDqTenantRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct DqRepositories {
  IDatasetRepository datasets;
  IRecordRepository records;
  IValidationRuleRepository validationRules;
  IViolationRepository violations;
  ICleansingRuleRepository cleansingRules;
  ICleansingJobRepository cleansingJobs;
  IMatchGroupRepository matchGroups;
  IColumnProfileRepository columnProfiles;
  IAddressRepository addresses;
  ISnapshotRepository snapshots;
  IUserAccountRepository users;
}
