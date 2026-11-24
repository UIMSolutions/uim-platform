/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.data_retention.persistence.repositories.repositories;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ApplicationGroupRepository : DocumentRepository!(ApplicationGroup, ApplicationGroupId), IApplicationGroupRepository {
  this(IDocumentStore store) {
    super(store, Collections.applicationGroups);
  }
}

class LegalEntityRepository : DocumentRepository!(LegalEntity, LegalEntityId), ILegalEntityRepository {
  this(IDocumentStore store) {
    super(store, Collections.legalEntities);
  }
}

class DataSubjectRoleRepository : DocumentRepository!(DataSubjectRole, DataSubjectRoleId), IDataSubjectRoleRepository {
  this(IDocumentStore store) {
    super(store, Collections.dataSubjectRoles);
  }
}

class BusinessPurposeRepository : DocumentRepository!(BusinessPurpose, BusinessPurposeId), IBusinessPurposeRepository {
  this(IDocumentStore store) {
    super(store, Collections.businessPurposes);
  }
}

class LegalGroundRepository : DocumentRepository!(LegalGround, LegalGroundId), ILegalGroundRepository {
  this(IDocumentStore store) {
    super(store, Collections.legalGrounds);
  }
}

class ResidenceRuleRepository : DocumentRepository!(ResidenceRule, ResidenceRuleId), IResidenceRuleRepository {
  this(IDocumentStore store) {
    super(store, Collections.residenceRules);
  }
}

class RetentionRuleRepository : DocumentRepository!(RetentionRule, RetentionRuleId), IRetentionRuleRepository {
  this(IDocumentStore store) {
    super(store, Collections.retentionRules);
  }
}

class DataSubjectRepository : DocumentRepository!(DataSubject, DataSubjectId), IDataSubjectRepository {
  this(IDocumentStore store) {
    super(store, Collections.dataSubjects);
  }
}

class DeletionRequestRepository : DocumentRepository!(DeletionRequest, DeletionRequestId), IDeletionRequestRepository {
  this(IDocumentStore store) {
    super(store, Collections.deletionRequests);
  }
}

class ArchivingJobRepository : DocumentRepository!(ArchivingJob, ArchivingJobId), IArchivingJobRepository {
  this(IDocumentStore store) {
    super(store, Collections.archivingJobs);
  }
}

class UserAccountRepository : DocumentRepository!(UserAccount, UserAccountId), IUserAccountRepository {
  this(IDocumentStore store) {
    super(store, Collections.users);
  }
}

/// All repositories over one document store.
DrRepositories createRepositories(IDocumentStore store) {
  DrRepositories r;
  r.applicationGroups = new ApplicationGroupRepository(store);
  r.legalEntities = new LegalEntityRepository(store);
  r.dataSubjectRoles = new DataSubjectRoleRepository(store);
  r.businessPurposes = new BusinessPurposeRepository(store);
  r.legalGrounds = new LegalGroundRepository(store);
  r.residenceRules = new ResidenceRuleRepository(store);
  r.retentionRules = new RetentionRuleRepository(store);
  r.dataSubjects = new DataSubjectRepository(store);
  r.deletionRequests = new DeletionRequestRepository(store);
  r.archivingJobs = new ArchivingJobRepository(store);
  r.users = new UserAccountRepository(store);
  return r;
}
