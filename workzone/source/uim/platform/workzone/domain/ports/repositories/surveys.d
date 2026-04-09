/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.surveys;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.survey;

interface SurveyRepository {
  Survey[] findByWorkspace(WorkspaceId workspacetenantId, id tenantId);
  Survey* findById(SurveyId tenantId, id tenantId);
  Survey[] findByStatus(SurveyStatus status, TenantId tenantId);
  Survey[] findByTenant(TenantId tenantId);
  void save(Survey survey);
  void update(Survey survey);
  void remove(SurveyId tenantId, id tenantId);
}
