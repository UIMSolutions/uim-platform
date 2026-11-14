/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reference data: translation domains and text types.
module uim.platform.translation.domain.services.catalogs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Translation domains (subject areas that select terminology).
immutable TranslationDomain[] translationDomains = [
  TranslationDomain("AU", "Automotive"), TranslationDomain("BA", "Banking"),
  TranslationDomain("CS", "Customer Service"), TranslationDomain("ED", "Education"),
  TranslationDomain("EN", "Energy"), TranslationDomain("FI", "Finance"),
  TranslationDomain("GV", "Government"), TranslationDomain("HC", "Healthcare"),
  TranslationDomain("HR", "Human Resources"), TranslationDomain("IN", "Insurance"),
  TranslationDomain("IT", "Information Technology"), TranslationDomain("LE", "Legal"),
  TranslationDomain("LO", "Logistics"), TranslationDomain("MA", "Manufacturing"),
  TranslationDomain("MK", "Marketing"), TranslationDomain("RE", "Retail"),
  TranslationDomain("SA", "Sales"), TranslationDomain("SC", "Supply Chain"),
  TranslationDomain("TC", "Telecommunications"), TranslationDomain("TR", "Travel"),
];

/// Text types with their recommended maximum length.
immutable TextTypeInfo[] textTypes = [
  TextTypeInfo("uiText", "UI Text", "Button labels, menu items, field labels", 40),
  TextTypeInfo("tooltip", "Tooltip", "Tooltip and help text", 120),
  TextTypeInfo("errorMessage", "Error Message", "Error and warning messages", 220),
  TextTypeInfo("documentation", "Documentation", "Long-form documentation and descriptions", 0),
  TextTypeInfo("notification", "Notification", "Push notifications and alert messages", 160),
  TextTypeInfo("emailBody", "E-Mail Body", "E-mail body and subject lines", 0),
  TextTypeInfo("reportTitle", "Report Title", "Report and chart titles", 60),
  TextTypeInfo("log", "Log Message", "Log and audit trail messages", 255),
];

/// True if `id` is a known domain ("" = general, always valid). Case-insensitive.
bool isKnownDomain(string id) {
  return id.length == 0 || translationDomains.any!(d => d.id == id.toUpper);
}

/// Validate and normalize a domain id ("fi" → "FI").
string requireDomain(string id) {
  auto d = id.strip.toUpper;
  validate(isKnownDomain(d), "Unknown translation domain '" ~ id ~ "' (see /domains)");
  return d;
}

/// The catalogue entry of a text type.
TextTypeInfo textTypeInfo(TextType type) {
  auto name = enumText(type);
  foreach (t; textTypes)
    if (t.id == name)
      return t;
  return TextTypeInfo.init;
}

///
unittest {
  assert(isKnownDomain("") && isKnownDomain("fi") && !isKnownDomain("XX"));
  assert(requireDomain(" hr ") == "HR");
  assert(textTypeInfo(TextType.uiText).recommendedMaxLength == 40);
  assert(textTypes.length == enumTexts!TextType.length);
}
