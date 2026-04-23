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

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  Survey[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);

  size_t countByStatus(TenantId tenantId, SurveyStatus status);
  Survey[] findByStatus(TenantId tenantId, SurveyStatus status);
  void removeByStatus(TenantId tenantId, SurveyStatus status);

}
