/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.translations;

// import uim.platform.portal.domain.entities.translation;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.translations;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemoryTranslationRepository : TranslationRepository {
  private Translation[TranslationId] store;

  bool existsById(TranslationId id) {
    return id in store ? true : false;
  }

  Translation findById(TranslationId id) {
    return existsById(id) ? store[id] : Translation.init;
  }

  Translation[] findByResource(string resourceType, string resourceId, string language = "") {
    Translation[] result;
    foreach (t; store.byValue()) {
      if (t.resourceType == resourceType && t.resourceId == resourceId) {
        if (language.length == 0 || t.language == language)
          result ~= t;
      }
    }
    return result;
  }

  Translation[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(t => t.tenantId == tenantId).array;
  }

  Translation[] findByLanguage(TenantId tenantId, string language, uint offset = 0, uint limit = 100) {
    Translation[] result;
    uint idx;
    foreach (t; findByTenant(tenantId)) {
      if (t.language == language) {
        if (idx >= offset && result.length < limit)
          result ~= t;
        idx++;
      }
    }
    return result;
  }

  void save(Translation translation) {
    store[translation.id] = translation;
  }

  void update(Translation translation) {
    store[translation.id] = translation;
  }

  void remove(TranslationId id) {
    store.remove(id);
  }

  void removeByResource(string resourceType, string resourceId) {
    TranslationId[] toRemove;
    foreach (kv; store.byKeyValue()) {
      if (kv.value.resourceType == resourceType && kv.value.resourceId == resourceId)
        toRemove ~= kv.key;
    }
    foreach (id; toRemove)
      store.remove(id);
  }
}
