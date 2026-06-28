/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.files.flex_changes;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// File-backed FlexChange repository.
/// Stores each change as a JSON file: {basePath}/FlexChange_{tenantId}_{id}.json
class FileFlexChangeRepository : TenantRepository!(FlexChange, FlexChangeId), FlexChangeRepository {
  private string basePath;

  this(string basePath) {
    this.basePath = basePath;
  }

  private string filePath(TenantId tenantId, FlexChangeId id) @trusted {
    import std.path : buildPath;
    return buildPath(basePath, "FlexChange_" ~ tenantId ~ "_" ~ id.value ~ ".json");
  }

  override FlexChangeId save(TenantId tenantId, FlexChange c) @trusted {
    import std.file : mkdirRecurse, write;
    mkdirRecurse(basePath);
    write(filePath(tenantId, c.id_), c.toJson().toString());
    super.save(tenantId, c);
    return c.id_;
  }

  override bool update(TenantId tenantId, FlexChange c) @trusted {
    import std.file : write;
    write(filePath(tenantId, c.id_), c.toJson().toString());
    super.update(tenantId, c);
    return true;
  }

  override bool remove(TenantId tenantId, FlexChangeId id) @trusted {
    import std.file : exists, remove;
    auto fp = filePath(tenantId, id);
    if (exists(fp)) remove(fp);
    super.remove(tenantId, id);
    return true;
  }

  bool existsById(TenantId tenantId, FlexChangeId id) {
    return !find(tenantId, id).isNull;
  }

  FlexChange findById(TenantId tenantId, FlexChangeId id) {
    foreach (c; find(tenantId))
      if (c.id_ == id) return c;
    return FlexChange.init;
  }

  bool removeById(TenantId tenantId, FlexChangeId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) find(tenantId).length;
  }

  FlexChange[] findByTenantAll(TenantId tenantId) {
    return find(tenantId);
  }

  FlexChange[] findByApp(TenantId tenantId, string appId) {
    FlexChange[] result;
    foreach (c; find(tenantId))
      if (c.appId_ == appId) result ~= c;
    return result;
  }

  FlexChange[] findByLayer(TenantId tenantId, string appId, ChangeLayer layer) {
    FlexChange[] result;
    foreach (c; find(tenantId))
      if (c.appId_ == appId && c.layer_ == layer) result ~= c;
    return result;
  }

  FlexChange[] findByChangeType(TenantId tenantId, string appId, ChangeType changeType) {
    FlexChange[] result;
    foreach (c; find(tenantId))
      if (c.appId_ == appId && c.changeType_ == changeType) result ~= c;
    return result;
  }
}
