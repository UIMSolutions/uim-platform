/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.translations;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

interface ITranslationRepository : ITenantRepository!(PortalTranslation, TranslationId) {
  PortalTranslation findByKey(TenantId tenantId, string key);
  PortalTranslation[] findByResource(TenantId tenantId, TranslatableType type, string resourceId);
  PortalTranslation[] findByLanguage(TenantId tenantId, string language);
}
