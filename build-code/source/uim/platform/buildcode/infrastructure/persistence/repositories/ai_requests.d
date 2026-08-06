/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.ai_requests;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class AIRequestRepository : TenantRepository!(AIRequest, AIRequestId), IAIRequestRepository {

  size_t countByProject(TenantId tenantId, string projectId) {
    return findByProject(tenantId, projectId).length;
  }

  AIRequest[] filterByProject(AIRequest[] requests, string projectId) {
    return requests.filter!(r => r.projectId.value == projectId).array
  }

  AIRequest[] findByProject(TenantId tenantId, string projectId) {
    return filterByProject(findByTenant(tenantId), projectId);
  }

  void deleteByProject(TenantId tenantId, string projectId) {
    findByProject(tenantId, projectId).each!(r => remove(r));
  }

  size_t countByStatus(TenantId tenantId, AIRequestStatus status) {
    return findByStatus(tenantId, status).length;
  }

  AIRequest[] filterByStatus(AIRequest[] requests, AIRequestStatus status) {
    return requests.filter!(r => r.status == status).array;
  }

  AIRequest[] findByStatus(TenantId tenantId, AIRequestStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, AIRequestStatus status) {
    findByStatus(tenantId, status).each!(r => remove(r));
  }

  size_t countByType(TenantId tenantId, AIGenerationType type) {
    return findByType(tenantId, type).length;
  }

  AIRequest[] filterByType(AIRequest[] requests, AIGenerationType type) {
    return requests.filter!(r => r.generationType == type).array;
  }

  AIRequest[] findByType(TenantId tenantId, AIGenerationType type) {
    return filterByType(findByTenant(tenantId), type);
  }

  void removeByType(TenantId tenantId, AIGenerationType type) {
    findByType(tenantId, type).each!(r => remove(r));
  }

  size_t countByUser(TenantId tenantId, string userId) {
    return findByUser(tenantId, userId).length;
  }

  AIRequest[] filterByUser(AIRequest[] requests, string userId) {
    return requests.filter!(r => r.requestedBy == userId).array;
  }

  AIRequest[] findByUser(TenantId tenantId, string userId) {
    return filterByUser(findByTenant(tenantId), userId);
  }

  void removeByUser(TenantId tenantId, string userId) {
    findByUser(tenantId, userId).each!(r => remove(r));
  }

}
