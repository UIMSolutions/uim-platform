/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.translation;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Translation entry for portal content (i18n).
struct Translation {
  TranslationId id;
  TenantId tenantId;
  string resourceType; // "site", "page", "tile", "section", "menuItem"
  string resourceId; // ID of the resource
  string fieldName; // "title", "description", etc.
  string language; // ISO 639-1 code (e.g., "de", "fr")
  string value; // translated text
  long createdAt;
  long updatedAt;
}
