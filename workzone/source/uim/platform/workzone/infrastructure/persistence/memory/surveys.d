/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.surveys;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.survey;
import uim.platform.workzone.domain.ports.repositories.surveys;

// import std.algorithm : filter;
// import std.array : array;

class MemorySurveyRepository : SurveyRepository {
  private Survey[SurveyId] store;

  Survey[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
  {
    return store.byValue().filter!(s => s.tenantId == tenantId && s.workspaceId == workspaceId).array;
  }

  Survey* findById(SurveyId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Survey[] findByStatus(SurveyStatus status, TenantId tenantId)
  {
    return store.byValue().filter!(s => s.tenantId == tenantId && s.status == status).array;
  }

  Survey[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(s => s.tenantId == tenantId).array;
  }

  void save(Survey survey)
  {
    store[survey.id] = survey;
  }

  void update(Survey survey)
  {
    store[survey.id] = survey;
  }

  void remove(SurveyId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
