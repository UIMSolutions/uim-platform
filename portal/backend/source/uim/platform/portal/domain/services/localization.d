/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Applies translations to content texts.
module uim.platform.portal.domain.services.localization;

import std.traits : FieldNameTuple;
import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// "de-CH" → "de"
string primaryLanguage(string language) pure {
  auto i = language.indexOf('-');
  if (i < 0)
    i = language.indexOf('_');
  return i < 0 ? language : language[0 .. i];
}

/// Replace the translatable text fields of `entity` with the translation for
/// `language` (exact match first, then the primary language).
T localized(T)(T entity, TranslatableType type, const PortalTranslation[] translations, string language) {
  if (language.length == 0)
    return entity;
  auto primary = primaryLanguage(language);
  auto fields = translatableFields(type);

  string lookup(string field) {
    string fallback;
    foreach (t; translations) {
      if (t.resourceType != type || t.resourceId != entity.id.value || t.fieldName != field)
        continue;
      if (t.language == language)
        return t.value;
      if (t.language == primary)
        fallback = t.value;
    }
    return fallback;
  }

  static foreach (name; FieldNameTuple!T) {
    static if (is(typeof(__traits(getMember, entity, name)) == string)) {
      if (fields.canFind(jsonKey(name))) {
        auto text = lookup(jsonKey(name));
        if (text.length > 0)
          __traits(getMember, entity, name) = text;
      }
    }
  }
  return entity;
}

/// Localize all texts of a site's content.
PortalContent localizedContent(PortalContent content, const PortalTranslation[] translations, string language) {
  if (language.length == 0 || translations.length == 0)
    return content;
  content.site = localized(content.site, TranslatableType.site, translations, language);
  foreach (ref p; content.pages)
    p = localized(p, TranslatableType.page, translations, language);
  foreach (ref s; content.sections)
    s = localized(s, TranslatableType.section, translations, language);
  foreach (ref t; content.tiles)
    t = localized(t, TranslatableType.tile, translations, language);
  foreach (ref c; content.catalogs)
    c = localized(c, TranslatableType.catalog, translations, language);
  foreach (ref m; content.menuItems)
    m = localized(m, TranslatableType.menuItem, translations, language);
  return content;
}

///
unittest {
  auto tile = PortalTile(TenantId("t"), TileId("x"));
  tile.name = "Orders";
  tile.subtitle = "Manage";
  auto de = PortalTranslation(TenantId("t"));
  de.resourceType = TranslatableType.tile;
  de.resourceId = "x";
  de.fieldName = "name";
  de.language = "de";
  de.value = "Aufträge";
  auto deCh = de;
  deCh.language = "de-CH";
  deCh.value = "Aufträg";

  assert(localized(tile, TranslatableType.tile, [de], "de").name == "Aufträge");
  assert(localized(tile, TranslatableType.tile, [de], "de-AT").name == "Aufträge"); // primary language
  assert(localized(tile, TranslatableType.tile, [de, deCh], "de-CH").name == "Aufträg");
  assert(localized(tile, TranslatableType.tile, [de], "fr").name == "Orders");
  assert(localized(tile, TranslatableType.tile, [de], "de").subtitle == "Manage");
  assert(primaryLanguage("pt_BR") == "pt");
}
