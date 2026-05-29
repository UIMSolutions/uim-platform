module uim.platform.market_refinitiv.infrastructure.persistence.file_.providers;

import uim.platform.market_refinitiv;
import uim.platform.market_refinitiv.infrastructure.persistence.codec;
import vibe.data.json : parseJsonString;
import std.file : exists, mkdirRecurse, write, readText, dirEntries, SpanMode, remove;
import std.path : buildPath;
import std.algorithm : filter;
import std.array : array;

@safe:

class FileProviderRepository : ProviderRepository {
  private string basePath;

  this(string rootPath) {
    basePath = buildPath(rootPath, "providers");
  }

  override Provider findById(TenantId tenantId, ProviderId id) @trusted {
    auto p = filePath(tenantId, id.value);
    if (!p.exists) return Provider.init;
    return providerFromJson(parseJsonString(readText(p)));
  }

  override Provider[] findByTenant(TenantId tenantId) @trusted {
    auto dir = tenantDir(tenantId);
    if (!dir.exists) return [];

    Provider[] results;
    foreach (e; dirEntries(dir, "*.json", SpanMode.shallow)) {
      try {
        results ~= providerFromJson(parseJsonString(readText(e.name)));
      } catch (Exception) {}
    }
    return results;
  }

  override void save(Provider p) {
    ensureTenantDir(p.tenantId);
    write(filePath(p.tenantId, p.id.value), toJsonDoc(p).toPrettyString());
  }

  override void update(Provider p) {
    save(p);
  }

  override void remove(Provider p) @trusted {
    auto path = filePath(p.tenantId, p.id.value);
    if (path.exists) std.file.remove(path);
  }

  override Provider findByCode(TenantId tenantId, string code) {
    foreach (p; findByTenant(tenantId)) {
      if (p.code == code) return p;
    }
    return Provider.init;
  }

  override Provider[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(p => p.isActive).array;
  }

  override bool codeExists(TenantId tenantId, string code) {
    return !findByCode(tenantId, code).isNull;
  }

  private string tenantDir(TenantId tenantId) const {
    return buildPath(basePath, tenantId);
  }

  private string filePath(TenantId tenantId, string id) const {
    return buildPath(tenantDir(tenantId), id ~ ".json");
  }

  private void ensureTenantDir(TenantId tenantId) @trusted {
    auto dir = tenantDir(tenantId);
    if (!dir.exists) mkdirRecurse(dir);
  }
}
