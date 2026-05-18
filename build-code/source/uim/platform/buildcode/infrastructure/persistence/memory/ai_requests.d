/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.memory.ai_requests;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class MemoryAIRequestRepository : AIRequestRepository {
  private AIRequest[string] _store;

  override void save(AIRequest entity)                { _store[entity.id.value] = entity; }
  override void update(AIRequest entity)              { _store[entity.id.value] = entity; }
  override void remove(string tenantId, AIRequestId id) { _store.remove(id.value); }

  override AIRequest findById(string tenantId, AIRequestId id) {
    if (id.value in _store) return _store[id.value];
    AIRequest r; return r;
  }

  override AIRequest[] findByTenant(string tenantId) {
    AIRequest[] result;
    foreach (r; _store.byValue)
      if (r.tenantId == tenantId) result ~= r;
    return result;
  }

  override AIRequest[] findByProject(string tenantId, string projectId) {
    AIRequest[] result;
    foreach (r; _store.byValue)
      if (r.tenantId == tenantId && r.projectId.value == projectId) result ~= r;
    return result;
  }

  override AIRequest[] findByStatus(string tenantId, AIRequestStatus status) {
    AIRequest[] result;
    foreach (r; _store.byValue)
      if (r.tenantId == tenantId && r.status == status) result ~= r;
    return result;
  }

  override AIRequest[] findByType(string tenantId, AIGenerationType type) {
    AIRequest[] result;
    foreach (r; _store.byValue)
      if (r.tenantId == tenantId && r.generationType == type) result ~= r;
    return result;
  }

  override AIRequest[] findByUser(string tenantId, string userId) {
    AIRequest[] result;
    foreach (r; _store.byValue)
      if (r.tenantId == tenantId && r.requestedBy == userId) result ~= r;
    return result;
  }
}
