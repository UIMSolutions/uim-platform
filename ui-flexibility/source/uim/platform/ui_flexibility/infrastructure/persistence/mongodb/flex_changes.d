/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.mongodb.flex_changes;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// MongoDB-backed FlexChange repository stub.
/// Delegates to MemoryFlexChangeRepository until full MongoDB impl is added.
/// Full MongoDB CRUD would use MongoClient and vibe.db.mongo with collection
/// "ui_flexibility.flex_changes" and queries by { tenantId, appId, changeType, layer }.
class MongoFlexChangeRepository : FlexChangeRepository {
  private MemoryFlexChangeRepository delegate_;

  this(string mongoUri) {
    // TODO: initialize MongoClient(mongoUri) and collection handle
    delegate_ = new MemoryFlexChangeRepository();
  }

  FlexChangeId save(string tenantId, FlexChange c) {
    return delegate_.save(tenantId, c);
  }

  bool update(string tenantId, FlexChange c) {
    return delegate_.update(tenantId, c);
  }

  bool remove(string tenantId, FlexChangeId id) {
    return delegate_.remove(tenantId, id);
  }

  FlexChange[] findByTenant(string tenantId) {
    return delegate_.findByTenant(tenantId);
  }

  bool existsById(string tenantId, FlexChangeId id) {
    return delegate_.existsById(tenantId, id);
  }

  FlexChange findById(string tenantId, FlexChangeId id) {
    return delegate_.findById(tenantId, id);
  }

  bool removeById(string tenantId, FlexChangeId id) {
    return delegate_.removeById(tenantId, id);
  }

  long countByTenant(string tenantId) {
    return delegate_.countByTenant(tenantId);
  }

  FlexChange[] findByTenantAll(string tenantId) {
    return delegate_.findByTenantAll(tenantId);
  }

  FlexChange[] findByApp(string tenantId, string appId) {
    return delegate_.findByApp(tenantId, appId);
  }

  FlexChange[] findByLayer(string tenantId, string appId, ChangeLayer layer) {
    return delegate_.findByLayer(tenantId, appId, layer);
  }

  FlexChange[] findByChangeType(string tenantId, string appId, ChangeType changeType) {
    return delegate_.findByChangeType(tenantId, appId, changeType);
  }
}
