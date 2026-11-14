/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.persistence.storages.snapshot_store;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Tenant store that keeps entities in memory and mirrors every change into an
/// ISnapshotStorage. Before each read it checks the storage revision and reloads
/// if another process changed the collection.
///
/// TMapper must provide "static Json toRecord(const TEntity)" and
/// "static TEntity fromRecord(Json)".
class SnapshotTenantStore(TEntity, TId, TMapper) : TenantStore!(TEntity, TId) {
  protected ISnapshotStorage _storage;
  protected string _collection;
  protected long _revision = -1;

  this(ISnapshotStorage storage, string collection) {
    super();
    _storage = storage;
    _collection = collection;
    refresh();
  }

  /// Reload from storage if the revision changed.
  void refresh() {
    auto rev = _storage.revision(_collection);
    if (rev == _revision)
      return;

    _entities = null;
    auto env = SnapshotEnvelope.fromJson(_collection, _storage.load(_collection));
    foreach (record; env.records) {
      auto entity = TMapper.fromRecord(record);
      if (entity.isNull)
        continue;
      if (entity.tenantId !in _entities) {
        TEntity[TId] fresh;
        _entities[entity.tenantId] = fresh;
      }
      _entities[entity.tenantId][entity.id] = entity;
    }
    _revision = rev;
  }

  /// Write the whole collection to storage.
  void persist() {
    SnapshotEnvelope env;
    env.collection = _collection;
    foreach (tenantId, byId; _entities)
      foreach (id, entity; byId)
        env.records ~= TMapper.toRecord(entity);
    _storage.store(_collection, env.toJson);
    _revision = _storage.revision(_collection);
  }

  // ── reads ──────────────────────────────────────────────────────────────
  override bool exists(TenantId tenantId) {
    refresh();
    return super.exists(tenantId);
  }

  override bool exists(TenantId tenantId, TId id) {
    refresh();
    return super.exists(tenantId, id);
  }

  override bool exists(TEntity entity) {
    refresh();
    return super.exists(entity);
  }

  override size_t count(TenantId tenantId) {
    refresh();
    return super.count(tenantId);
  }

  override size_t count(TenantId tenantId, bool delegate(TEntity) @safe predicate) {
    refresh();
    return super.count(tenantId, predicate);
  }

  override TEntity[] find(TenantId tenantId, size_t offset = 0, size_t limit = 0) {
    refresh();
    return super.find(tenantId, offset, limit);
  }

  override TEntity find(TenantId tenantId, TId id) {
    refresh();
    return super.find(tenantId, id);
  }

  // ── writes ─────────────────────────────────────────────────────────────
  override void save(TEntity entity) {
    refresh();
    super.save(entity);
    persist();
  }

  override void save(TEntity[] entities) {
    refresh();
    foreach (e; entities)
      super.save(e);
    persist();
  }

  override void update(TEntity entity) {
    refresh();
    super.update(entity);
    persist();
  }

  override void update(TEntity[] entities) {
    refresh();
    foreach (e; entities)
      super.update(e);
    persist();
  }

  override void remove(TenantId tenantId) {
    refresh();
    super.remove(tenantId);
    persist();
  }

  override void remove(TenantId tenantId, TId id) {
    refresh();
    super.remove(tenantId, id);
    persist();
  }

  override void remove(TEntity entity) {
    refresh();
    super.remove(entity);
    persist();
  }

  override void remove(TEntity[] entities) {
    refresh();
    foreach (e; entities)
      super.remove(e);
    persist();
  }
}
///
unittest {
  mixin(ShowTest!("SnapshotTenantStore"));

  auto storage = new MemorySnapshotStorage();
  auto tenant = TenantId("t1");

  auto a = new SnapshotTenantStore!(Certificate, CertificateId, CertificateMapper)(storage, ConnectivityCollections.certificates);
  auto cert = Certificate(tenant);
  cert.name = "client-cert";
  cert.subjectDN = "CN=client";
  a.save(cert);

  // a second store on the same storage (= another process) sees the entry
  auto b = new SnapshotTenantStore!(Certificate, CertificateId, CertificateMapper)(storage, ConnectivityCollections.certificates);
  assert(b.count(tenant) == 1);
  assert(b.find(tenant, cert.id).subjectDN == "CN=client");

  b.remove(tenant, cert.id);
  assert(a.count(tenant) == 0); // a reloads after b's change
}
