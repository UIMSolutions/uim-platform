/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.data_retention.ports.repositories.repositories;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IApplicationGroupRepository : IDrRepository!(ApplicationGroup, ApplicationGroupId) {
}

interface ILegalEntityRepository : IDrRepository!(LegalEntity, LegalEntityId) {
}

interface IDataSubjectRoleRepository : IDrRepository!(DataSubjectRole, DataSubjectRoleId) {
}

interface IBusinessPurposeRepository : IDrRepository!(BusinessPurpose, BusinessPurposeId) {
}

interface ILegalGroundRepository : IDrRepository!(LegalGround, LegalGroundId) {
}

interface IResidenceRuleRepository : IDrRepository!(ResidenceRule, ResidenceRuleId) {
}

interface IRetentionRuleRepository : IDrRepository!(RetentionRule, RetentionRuleId) {
}

interface IDataSubjectRepository : IDrRepository!(DataSubject, DataSubjectId) {
}

interface IDeletionRequestRepository : IDrRepository!(DeletionRequest, DeletionRequestId) {
}

interface IArchivingJobRepository : IDrRepository!(ArchivingJob, ArchivingJobId) {
}

interface IUserAccountRepository : IDrRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct DrRepositories {
  IApplicationGroupRepository applicationGroups;
  ILegalEntityRepository legalEntities;
  IDataSubjectRoleRepository dataSubjectRoles;
  IBusinessPurposeRepository businessPurposes;
  ILegalGroundRepository legalGrounds;
  IResidenceRuleRepository residenceRules;
  IRetentionRuleRepository retentionRules;
  IDataSubjectRepository dataSubjects;
  IDeletionRequestRepository deletionRequests;
  IArchivingJobRepository archivingJobs;
  IUserAccountRepository users;
}
