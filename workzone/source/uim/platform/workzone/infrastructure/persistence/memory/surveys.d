/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.surveys;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.survey;
// import uim.platform.workzone.domain.ports.repositories.surveys;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemorySurveyRepository : TenantRepository!(Survey, SurveyId), SurveyRepository {

  // #region ByWorkspace
  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  Survey[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(s => s.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    findByWorkspace(tenantId, workspaceId).each!(s => remove(s));
  }
  // #endregion ByWorkspace

  // #region ByOrganizer
  size_t countByOrganizer(TenantId tenantId, UserId organizerId) {
    return findByOrganizer(tenantId, organizerId).length;
  }

  Survey[] findByOrganizer(TenantId tenantId, UserId organizerId) {
    return findByTenant(tenantId).filter!(s => s.organizerId == organizerId).array;
  }

  void removeByOrganizer(TenantId tenantId, UserId organizerId) {
    findByOrganizer(tenantId, organizerId).each!(s => remove(s));
  }
  // #endregion ByOrganizer

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, SurveyStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Survey[] findByStatus(TenantId tenantId, SurveyStatus status) {
    return findAll().filter!(s => s.tenantId == tenantId && s.status == status).array;
  }

  void removeByStatus(TenantId tenantId, SurveyStatus status) {
    findByStatus(tenantId, status).each!(s => remove(s));
  }
  // #endregion ByStatus

}
