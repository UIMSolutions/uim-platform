/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.infrastructure.persistence.repositories.audits;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for audit event persistence (append-only).
class AuditRepository : TenantRepository!(AuditEvent, AuditEventId), IAuditRepository {

  // #region ByActor
  size_t countByActor(TenantId tenantId, string actorId) {
    return findByActor(tenantId, actorId).length;
  }

  AuditEvent[] filterByActor(AuditEvent[] events, string actorId, size_t offset = 0, size_t limit = 100) {
    return events.filter!(e => e.actorId == actorId).array.skip(offset).limit(limit);
  }

  AuditEvent[] findByActor(TenantId tenantId, string actorId) {
    return filterByActor(findByTenant(tenantId), actorId);
  }

  void removeByActor(TenantId tenantId, string actorId) {
    findByActor(tenantId, actorId).each!(e => remove(e));
  }
  // #endregion ByActor

  // #region ByTarget
  size_t countByTarget(TenantId tenantId, string targetId) {
    return findByTarget(tenantId, targetId).length;
  }

  AuditEvent[] filterByTarget(AuditEvent[] events, string targetId, size_t offset = 0, size_t limit = 100) {
    return events.filter!(e => e.targetId == targetId).array.skip(offset).limit(limit);
  }

  AuditEvent[] findByTarget(TenantId tenantId, string targetId) {
    return filterByTarget(findByTenant(tenantId), targetId);
  }

  void removeByTarget(TenantId tenantId, string targetId) {
    findByTarget(tenantId, targetId).each!(e => remove(e));
  }
  // #endregion ByTarget

  // #region ByType
  size_t countByType(TenantId tenantId, AuditEventType eventType) {
    return findByType(tenantId, eventType).length;
  }

  AuditEvent[] filterByType(AuditEvent[] events, TenantId tenantId, AuditEventType eventType, size_t offset = 0, size_t limit = 100) {
    return events.filter!(e => e.tenantId == tenantId && e.eventType == eventType).array.skip(offset).limit(limit);
  }

  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType) {
    return filterByType(findByTenant(tenantId), tenantId, eventType);
  }

  void removeByType(TenantId tenantId, AuditEventType eventType) {
    findByType(tenantId, eventType).each!(e => remove(e));
  }
  // #endregion ByType

  // #region ByTimeRange
  size_t countByTimeRange(TenantId tenantId, long from, long to) {
    return findByTimeRange(tenantId, from, to).length;
  }

  AuditEvent[] filterByTimeRange(AuditEvent[] events, long from, long to, size_t offset = 0, size_t limit = 100) {
    return events.filter!(e => e.timestamp >= from && e.timestamp <= to).array.skip(offset).limit(limit);
  }

  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to) {
    return filterByTimeRange(findByTenant(tenantId), from, to);
  }

  void removeByTimeRange(TenantId tenantId, long from, long to) {
    findByTimeRange(tenantId, from, to).each!(e => remove(e));
  }
  // #endregion ByTimeRange

}

///
unittest {
  mixin(ShowTest!("AuditRepository"));

  void testCountByActor() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto actorId = "test-actor";

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = actorId;
    event1.targetId = "target1";
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = actorId;
    event2.targetId = "target2";
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = currentTimestamp;
    repo.save(event2);

    assert(repo.countByActor(tenantId, actorId) == 2);
  }

  void testFindByActor() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto actorId = "test-actor";

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = actorId;
    event1.targetId = "target1";
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = actorId;
    event2.targetId = "target2";
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = currentTimestamp;
    repo.save(event2);

    auto events = repo.findByActor(tenantId, actorId);
    assert(events.length == 2);
  }
  
  void testRemoveByActor() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto actorId = "test-actor";

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = actorId;
    event1.targetId = "target1";
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = actorId;
    event2.targetId = "target2";
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = currentTimestamp;
    repo.save(event2);
    
    repo.removeByActor(tenantId, actorId);
    assert(repo.countByActor(tenantId, actorId) == 0);
  }

  void testCountByTarget() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto targetId = "test-target";

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = targetId;
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = targetId;
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = currentTimestamp;
    repo.save(event2);

    assert(repo.countByTarget(tenantId, targetId) == 2);
  }

  void testFindByTarget() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto targetId = "test-target";

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = targetId;
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = targetId;
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = currentTimestamp;
    repo.save(event2);

    auto events = repo.findByTarget(tenantId, targetId);
    assert(events.length == 2);
  }

  void testRemoveByTarget() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto targetId = "test-target";

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = targetId;
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = targetId;
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = currentTimestamp;
    repo.save(event2);
    
    repo.removeByTarget(tenantId, targetId);
    assert(repo.countByTarget(tenantId, targetId) == 0);
  }

  void testCountByType() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto eventType = AuditEventType.loginSuccess;

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = "target1";
    event1.eventType = eventType;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = "target2";
    event2.eventType = eventType;
    event2.timestamp = currentTimestamp;
    repo.save(event2);
    
    assert(repo.countByType(tenantId, eventType) == 2);
  }

  void testFindByType() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto eventType = AuditEventType.loginSuccess;
    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = "target1";
    event1.eventType = eventType;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = "target2";
    event2.eventType = eventType;
    event2.timestamp = currentTimestamp;
    repo.save(event2);

    auto events = repo.findByType(tenantId, eventType);
    assert(events.length == 2);
  }

  void testRemoveByType() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto eventType = AuditEventType.loginSuccess;

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = "target1";
    event1.eventType = eventType;
    event1.timestamp = currentTimestamp;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = "target2";
    event2.eventType = eventType;
    event2.timestamp = currentTimestamp;
    repo.save(event2);

    repo.removeByType(tenantId, eventType);
    assert(repo.countByType(tenantId, eventType) == 0);
  }

  void testCountByTimeRange() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto now = currentTimestamp;
    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = "target1";
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = now - 1000;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = "target2";
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = now;
    repo.save(event2);
    assert(repo.countByTimeRange(tenantId, now - 2000, now + 1000) == 2);
  }

  void testFindByTimeRange() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto now = currentTimestamp;
    
    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = "target1";
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = now - 1000;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = "target2";
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = now;
    repo.save(event2);
    
    auto events = repo.findByTimeRange(tenantId, now - 2000, now + 1000);
    assert(events.length == 2);
  }

  void testRemoveByTimeRange() {
    auto repo = new AuditRepository();
    auto tenantId = TenantId("test-tenant");
    auto now = currentTimestamp;

    auto event1 = AuditEvent(tenantId, AuditEventId("event1"));
    event1.actorId = "actor1";
    event1.targetId = "target1";
    event1.eventType = AuditEventType.loginSuccess;
    event1.timestamp = now - 1000;
    repo.save(event1);

    auto event2 = AuditEvent(tenantId, AuditEventId("event2"));
    event2.actorId = "actor2";
    event2.targetId = "target2";
    event2.eventType = AuditEventType.loginFailure;
    event2.timestamp = now;
    repo.save(event2);
    
    repo.removeByTimeRange(tenantId, now - 2000, now + 1000);
    assert(repo.countByTimeRange(tenantId, now - 2000, now + 1000) == 0);
  }

  void testAll() {
    testCountByActor();
    testFindByActor();
    testRemoveByActor();
    testCountByTarget();
    testFindByTarget();
    testRemoveByTarget();
    testCountByType();
    testFindByType();
    testRemoveByType();
    testCountByTimeRange();
    testFindByTimeRange();
    testRemoveByTimeRange();
  }

  testAll();

}