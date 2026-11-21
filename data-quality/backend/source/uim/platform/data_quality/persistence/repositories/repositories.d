/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.data_quality.persistence.repositories.repositories;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class DatasetRepository : TenantDocumentRepository!(Dataset, DatasetId, datasetToRecord, recordToDataset), IDatasetRepository {
  this(IDocumentStore store) {
    super(store, Collections.datasets);
  }
}

class RecordRepository : ScopedDocumentRepository!(DataRecord, RecordId, recordToDocument, documentToRecord), IRecordRepository {
  this(IDocumentStore store) {
    super(store, Collections.records);
  }
}

class ValidationRuleRepository : TenantDocumentRepository!(ValidationRule, ValidationRuleId, validationRuleToRecord,
  recordToValidationRule), IValidationRuleRepository {
  this(IDocumentStore store) {
    super(store, Collections.validationRules);
  }
}

class ViolationRepository : ScopedDocumentRepository!(Violation, ViolationId, violationToRecord, recordToViolation),
IViolationRepository {
  this(IDocumentStore store) {
    super(store, Collections.violations);
  }

  Violation[] findByRecord(TenantId t, DatasetId ds, RecordId record) {
    return whereDocument(t, (Json d) => textField(d, "datasetId") == ds.value && textField(d, "recordId") == record.value);
  }

  size_t removeByRecord(TenantId t, DatasetId ds, RecordId record) {
    size_t removed;
    foreach (v; findByRecord(t, ds, record))
      if (removeById(t, ds, v.id))
        removed++;
    return removed;
  }
}

class CleansingRuleRepository : TenantDocumentRepository!(CleansingRule, CleansingRuleId, cleansingRuleToRecord,
  recordToCleansingRule), ICleansingRuleRepository {
  this(IDocumentStore store) {
    super(store, Collections.cleansingRules);
  }
}

class CleansingJobRepository : ScopedDocumentRepository!(CleansingJob, CleansingJobId, cleansingJobToRecord,
  recordToCleansingJob), ICleansingJobRepository {
  this(IDocumentStore store) {
    super(store, Collections.cleansingJobs);
  }

  CleansingJob[] findByStatus(TenantId t, JobStatus status) {
    return whereDocument(t, (Json d) => textField(d, "status") == cast(string) status);
  }
}

class MatchGroupRepository : ScopedDocumentRepository!(MatchGroup, MatchGroupId, matchGroupToRecord, recordToMatchGroup),
IMatchGroupRepository {
  this(IDocumentStore store) {
    super(store, Collections.matchGroups);
  }
}

class ColumnProfileRepository : ScopedDocumentRepository!(ColumnProfile, ColumnProfileId, columnProfileToRecord,
  recordToColumnProfile), IColumnProfileRepository {
  this(IDocumentStore store) {
    super(store, Collections.columnProfiles);
  }
}

class AddressRepository : TenantDocumentRepository!(PostalAddress, AddressId, addressToRecord, recordToAddress), IAddressRepository {
  this(IDocumentStore store) {
    super(store, Collections.addresses);
  }
}

class SnapshotRepository : ScopedDocumentRepository!(QualitySnapshot, SnapshotId, snapshotToRecord, recordToSnapshot),
ISnapshotRepository {
  this(IDocumentStore store) {
    super(store, Collections.snapshots);
  }
}

/// All repositories over one document store.
DqRepositories createRepositories(IDocumentStore store) {
  DqRepositories r;
  r.datasets = new DatasetRepository(store);
  r.records = new RecordRepository(store);
  r.validationRules = new ValidationRuleRepository(store);
  r.violations = new ViolationRepository(store);
  r.cleansingRules = new CleansingRuleRepository(store);
  r.cleansingJobs = new CleansingJobRepository(store);
  r.matchGroups = new MatchGroupRepository(store);
  r.columnProfiles = new ColumnProfileRepository(store);
  r.addresses = new AddressRepository(store);
  r.snapshots = new SnapshotRepository(store);
  return r;
}
