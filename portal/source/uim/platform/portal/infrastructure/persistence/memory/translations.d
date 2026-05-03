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
class MemoryTranslationRepository : TenantRepository!(Translation, TranslationId), TranslationRepository {

  size_t countByResource(string resourceType, string resourceId) {
    return findByResource(resourceType, resourceId).length;
  }
  Translation[] findByResource(string resourceType, string resourceId, string language = "") {
    Translation[] result;
    foreach (t; findAll())
      if (t.resourceType == resourceType && t.resourceId == resourceId) {
        if (language.length == 0 || t.language == language)
          result ~= t;
      }
    }
    return result;
  }
  void removeByResource(string resourceType, string resourceId) {
    findByResource(resourceType, resourceId).each!(t => remove(t));
  }

  size_t countByLanguage(TenantId tenantId, string language) {
    return findByLanguage(tenantId, language).length;
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

  void removeByLanguage(TenantId tenantId, string language) {
    findByLanguage(tenantId, language).each!(t => remove(t));
  }

}
