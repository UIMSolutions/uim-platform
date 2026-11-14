/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.translation;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A translated text of a content field (i18n), e.g. the German "name" of a tile.
struct PortalTranslation {
  mixin TenantEntity!TranslationId;

  TranslatableType resourceType = TranslatableType.tile;
  /// Id of the translated site / page / section / tile / catalog / menu item.
  string resourceId;
  /// Translated field ("name", "description", "subtitle", ...).
  string fieldName = "name";
  /// Language code (ISO 639-1, optionally with region: "de", "pt-BR").
  string language;
  string value;
  /// Technical key "<resourceType>/<resourceId>/<fieldName>/<language>".
  string name;

  static string keyOf(TranslatableType type, string resourceId, string fieldName, string language) {
    return enumText(type) ~ "/" ~ resourceId ~ "/" ~ fieldName ~ "/" ~ language;
  }
}
