/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.translation_repository;

import uim.platform.portal.domain.entities.translation;
import uim.platform.portal.domain.types;

/// Port: outgoing — translation persistence.
interface TranslationRepository
{
  Translation findById(TranslationId id);
  Translation[] findByResource(string resourceType, string resourceId, string language = "");
  Translation[] findByLanguage(TenantId tenantId, string language, uint offset = 0, uint limit = 100);
  void save(Translation translation);
  void update(Translation translation);
  void remove(TranslationId id);
  void removeByResource(string resourceType, string resourceId);
}
