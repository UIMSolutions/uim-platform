/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Master data maintenance: application groups, legal entities and data
/// subject roles. Master data in use cannot be deleted.
module uim.platform.data_retention.application.usecases.master_data;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageApplicationGroupsUseCase : ResourceInteractor!(ApplicationGroup, ApplicationGroupId, ApplicationGroupInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(ApplicationGroup, ApplicationGroupId) store() {
    return repos.applicationGroups;
  }

  protected override string what() {
    return "Application group";
  }

  protected override string eventPrefix() {
    return "applicationGroup";
  }

  protected override ApplicationGroupInput toInput(const ApplicationGroup e) {
    return ApplicationGroupInput(e.name, e.description, cast(string) e.scope_, e.applicationIds.dup, e.active);
  }

  protected override void fromInput(TenantId t, ref ApplicationGroup e, ApplicationGroupInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.scope_ = parseDomainEnumOr!ApplicationGroupScope(i.scope_, ApplicationGroupScope.global, "scope");
    e.applicationIds = uniqueTexts(i.applicationIds);
    e.active = i.active;
  }

  protected override void beforeRemove(TenantId t, const ApplicationGroup e, UserId actor) {
    auto what = "Application group '" ~ e.id.value ~ "'";
    requireUnused(what, repos.businessPurposes.countByReference(t, "applicationGroupId", e.id.value), "business purposes");
    requireUnused(what, repos.dataSubjects.countByReference(t, "applicationGroupId", e.id.value), "data subjects");
    requireUnused(what, repos.archivingJobs.countByReference(t, "applicationGroupId", e.id.value), "archiving jobs");
  }
}

class ManageLegalEntitiesUseCase : ResourceInteractor!(LegalEntity, LegalEntityId, LegalEntityInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(LegalEntity, LegalEntityId) store() {
    return repos.legalEntities;
  }

  protected override string what() {
    return "Legal entity";
  }

  protected override string eventPrefix() {
    return "legalEntity";
  }

  protected override LegalEntityInput toInput(const LegalEntity e) {
    return LegalEntityInput(e.name, e.description, e.country, e.region, e.active);
  }

  protected override void fromInput(TenantId t, ref LegalEntity e, LegalEntityInput i, bool creating) {
    import std.uni : toUpper;

    e.name = i.name.strip;
    e.description = i.description.strip;
    e.country = i.country.strip.toUpper;
    e.region = i.region.strip;
    e.active = i.active;
  }

  protected override void beforeRemove(TenantId t, const LegalEntity e, UserId actor) {
    auto what = "Legal entity '" ~ e.id.value ~ "'";
    requireUnused(what, repos.businessPurposes.countByReference(t, "legalEntityId", e.id.value), "business purposes");
    requireUnused(what, repos.dataSubjects.countByReference(t, "legalEntityId", e.id.value), "data subjects");
  }
}

class ManageDataSubjectRolesUseCase : ResourceInteractor!(DataSubjectRole, DataSubjectRoleId, DataSubjectRoleInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(DataSubjectRole, DataSubjectRoleId) store() {
    return repos.dataSubjectRoles;
  }

  protected override string what() {
    return "Data subject role";
  }

  protected override string eventPrefix() {
    return "dataSubjectRole";
  }

  protected override DataSubjectRoleInput toInput(const DataSubjectRole e) {
    return DataSubjectRoleInput(e.name, e.description, e.active);
  }

  protected override void fromInput(TenantId t, ref DataSubjectRole e, DataSubjectRoleInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.active = i.active;
  }

  protected override void beforeRemove(TenantId t, const DataSubjectRole e, UserId actor) {
    auto what = "Data subject role '" ~ e.id.value ~ "'";
    requireUnused(what, repos.businessPurposes.countByReference(t, "dataSubjectRoleId", e.id.value), "business purposes");
    requireUnused(what, repos.dataSubjects.countByReference(t, "dataSubjectRoleId", e.id.value), "data subjects");
  }
}
