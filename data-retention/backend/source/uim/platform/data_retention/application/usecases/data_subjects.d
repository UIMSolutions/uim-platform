/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Data subject registry. Every data subject that is returned carries its
/// retention evaluation, computed from the current rules (so a changed
/// rule takes effect at once, nothing is stale).
///
///   - the external id is unique per application group
///   - application group, role and legal entity default to the business purpose's
///   - deprecated purposes accept no new data subjects
///   - destroyed data subjects cannot be changed
module uim.platform.data_retention.application.usecases.data_subjects;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectsUseCase : ResourceInteractor!(DataSubject, DataSubjectId, DataSubjectInput), IManageDataSubjects {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(DataSubject, DataSubjectId) store() {
    return repos.dataSubjects;
  }

  protected override string what() {
    return "Data subject";
  }

  protected override string eventPrefix() {
    return "dataSubject";
  }

  protected override DataSubjectInput toInput(const DataSubject e) {
    return DataSubjectInput(e.externalId, e.displayName, e.applicationGroupId.value, e.dataSubjectRoleId.value,
      e.businessPurposeId.value, e.legalGroundId.value, e.legalEntityId.value, isoDateText(e.referenceDate));
  }

  protected override void fromInput(TenantId t, ref DataSubject e, DataSubjectInput i, bool creating) {
    if (!creating && e.isDeleted)
      throw DataRetentionException.ruleViolation("Data subject '" ~ e.id.value ~ "' is destroyed and cannot be changed");
    auto purpose = businessPurposeOf(t, i.businessPurposeId);
    if (purpose.status == BusinessPurposeStatus.deprecated_ && (creating || purpose.id != e.businessPurposeId))
      throw DataRetentionException.ruleViolation("Business purpose '" ~ purpose.id.value ~ "' is deprecated and accepts "
          ~ "no new data subjects");
    e.businessPurposeId = purpose.id;
    e.applicationGroupId = applicationGroupOf(t, i.applicationGroupId.strip.length ? i.applicationGroupId
        : purpose.applicationGroupId.value).id;
    e.dataSubjectRoleId = DataSubjectRoleId(optionalReference!DataSubjectRoleId(repos.dataSubjectRoles, t,
        i.dataSubjectRoleId.strip.length ? i.dataSubjectRoleId : purpose.dataSubjectRoleId.value, "Data subject role"));
    e.legalEntityId = LegalEntityId(optionalReference!LegalEntityId(repos.legalEntities, t,
        i.legalEntityId.strip.length ? i.legalEntityId : purpose.legalEntityId.value, "Legal entity"));
    e.legalGroundId = LegalGroundId.init;
    if (i.legalGroundId.strip.length) {
      auto g = legalGroundOf(t, i.legalGroundId);
      if (g.businessPurposeId != purpose.id)
        throw DataRetentionException.invalid("Legal ground '" ~ g.id.value ~ "' does not belong to business purpose '"
            ~ purpose.id.value ~ "'");
      e.legalGroundId = g.id;
    }
    e.externalId = i.externalId.strip;
    e.displayName = i.displayName.strip;
    e.referenceDate = parseIsoTime(i.referenceDate, "Reference date");
    if (e.referenceDate > plusDays(now, 1))
      throw DataRetentionException.invalid("The reference date (end of business) must not be in the future");
    requireText(e.externalId, "External ID");
    foreach (other; repos.dataSubjects.findByReference(t, "applicationGroupId", e.applicationGroupId.value))
      if (other.id != e.id && other.externalId == e.externalId)
        throw DataRetentionException.conflict("External ID '" ~ e.externalId ~ "' is already registered in application group '"
            ~ e.applicationGroupId.value ~ "' (data subject '" ~ other.id.value ~ "')");
  }

  protected override void beforeRemove(TenantId t, const DataSubject e, UserId actor) {
    if (e.legalHold)
      throw DataRetentionException.ruleViolation("Data subject '" ~ e.id.value ~ "' is on legal hold and cannot be deleted");
    foreach (r; repos.deletionRequests.findByReference(t, "dataSubjectId", e.id.value))
      repos.deletionRequests.removeById(t, r.id);
  }

  protected override DataSubject[] decorate(TenantId t, DataSubject[] subjects) {
    return new RuleBook(repos, t).evaluated(subjects, now);
  }

  DataSubject block(TenantId t, DataSubjectId id, UserId actor) {
    auto s = dataSubjectOf(t, id);
    if (s.isBlocked)
      throw DataRetentionException.ruleViolation("Data subject '" ~ id.value ~ "' is already " ~ cast(string) s.lifecycleStatus);
    s.block(now);
    return changed(s, actor, "blocked");
  }

  DataSubject setLegalHold(TenantId t, DataSubjectId id, bool legalHold, string reason, UserId actor) {
    auto s = dataSubjectOf(t, id);
    s.setLegalHold(legalHold, reason);
    return changed(s, actor, legalHold ? "legalHoldSet" : "legalHoldReleased");
  }

  DataSubject[] listByApplicationGroup(TenantId t, ApplicationGroupId group) {
    return decorate(t, group.isNull ? repos.dataSubjects.findAll(t)
        : repos.dataSubjects.findByReference(t, "applicationGroupId", group.value));
  }

  protected DataSubject changed(DataSubject s, UserId actor, string event) {
    stampUpdated(s, actor, now);
    repos.dataSubjects.save(s);
    emit("dataSubject." ~ event, s.tenantId, s.id.value, Json(["status": Json(cast(string) s.lifecycleStatus)]));
    return decorateOne(s.tenantId, s);
  }
}
