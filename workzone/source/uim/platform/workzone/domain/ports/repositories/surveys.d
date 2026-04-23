/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.surveys;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.survey;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface SurveyRepository : ITenantRepository!(Survey, SurveyId) {

  size_t countByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
  Survey[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
  void removeByWorkspace(WorkspaceId workspaceId, TenantId tenantId);

  size_t countByStatus(SurveyStatus status, TenantId tenantId);
  Survey[] findByStatus(SurveyStatus status, TenantId tenantId);
  void removeByStatus(SurveyStatus status, TenantId tenantId);

}
