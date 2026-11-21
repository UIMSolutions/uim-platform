/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: applies cleansing rules to the fields of a record.
/// Rules run in the given order; each sees the result of the previous one.
module uim.platform.data_quality.domain.services.cleansing_engine;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct CleansingOutcome {
  FieldValue[] fields;
  string[] changes; /// "field: old → new (rule)"
  size_t changedFields; /// number of rule applications that changed a value

  bool changed() const {
    return changedFields > 0;
  }
}

/// Value of valueField in the record of dataset whose keyField equals key;
/// false if there is none.
alias EnrichmentLookup = bool delegate(string dataset, string keyField, string key, string valueField, out string value) @safe;

class CleansingEngine {
  protected Regex!char[string] regexCache;

  CleansingOutcome apply(const CleansingRule[] rules, const FieldValue[] input, scope EnrichmentLookup lookup = null) {
    CleansingOutcome o;
    o.fields = withoutField(input, ""); // mutable copy
    foreach (ref rule; rules) {
      auto present = hasField(o.fields, rule.fieldName);
      auto before = fieldOf(o.fields, rule.fieldName);
      string after = before;
      bool remove;

      final switch (rule.action) {
      case CleansingAction.trim:
        after = before.strip;
        break;
      case CleansingAction.collapseWhitespace:
        after = collapseWhitespace(before);
        break;
      case CleansingAction.upperCase:
        after = before.toUpper;
        break;
      case CleansingAction.lowerCase:
        after = before.toLower;
        break;
      case CleansingAction.titleCase:
        after = titleCase(before);
        break;
      case CleansingAction.removeDiacritics:
        after = removeDiacritics(before);
        break;
      case CleansingAction.replace:
        if (present)
          after = replaceAll(before, compiled(rule.findPattern), rule.replaceWith);
        break;
      case CleansingAction.defaultValue:
        if (before.strip.length == 0)
          after = rule.defaultValue;
        break;
      case CleansingAction.clear:
        remove = present;
        break;
      case CleansingAction.standardizeCountry:
        auto iso = countryCode(before);
        if (iso.length)
          after = iso;
        break;
      case CleansingAction.enrich:
        if (lookup is null)
          break;
        auto key = fieldOf(o.fields, rule.sourceField).strip;
        string found;
        if (key.length && lookup(rule.lookupDataset, rule.lookupKeyField, key, rule.lookupValueField, found))
          after = found;
        break;
      }

      if (remove) {
        o.fields = withoutField(o.fields, rule.fieldName);
        o.changes ~= format("%s: removed '%s' (%s)", rule.fieldName, clip(before), rule.name);
        o.changedFields++;
      } else if (after != before || (!present && after.length > 0)) {
        if (!present && after.length == 0)
          continue;
        o.fields = withField(o.fields, rule.fieldName, after);
        o.changes ~= format("%s: '%s' → '%s' (%s)", rule.fieldName, clip(before), clip(after), rule.name);
        o.changedFields++;
      }
    }
    return o;
  }

  protected Regex!char compiled(string pattern) @trusted {
    if (auto r = pattern in regexCache)
      return *r;
    if (regexCache.length > 512)
      regexCache = null;
    auto r = regex(pattern);
    regexCache[pattern] = r;
    return r;
  }
}

///
unittest {
  CleansingRule rule(string field, CleansingAction action) {
    CleansingRule r;
    r.id = CleansingRuleId(field ~ cast(string) action);
    r.name = cast(string) action;
    r.fieldName = field;
    r.action = action;
    r.status = RuleStatus.active;
    return r;
  }

  auto trim = rule("email", CleansingAction.trim);
  auto lower = rule("email", CleansingAction.lowerCase);
  auto phone = rule("phone", CleansingAction.replace);
  phone.findPattern = `[^0-9+]`;
  phone.replaceWith = "";
  auto country = rule("country", CleansingAction.standardizeCountry);
  auto status = rule("status", CleansingAction.defaultValue);
  status.defaultValue = "active";
  auto region = rule("countryName", CleansingAction.enrich);
  region.lookupDataset = "countries";
  region.lookupKeyField = "code";
  region.lookupValueField = "name";
  region.sourceField = "country";
  auto fax = rule("fax", CleansingAction.clear);

  auto engine = new CleansingEngine;
  auto o = engine.apply([trim, lower, phone, country, status, region, fax], [FieldValue("email", "  Ada@Example.ORG "),
      FieldValue("phone", "+49 (30) 123-45"), FieldValue("country", "Germany"), FieldValue("fax", "1")],
    (string ds, string kf, string key, string vf, out string value) {
      value = key == "DE" ? "Germany" : "";
      return key == "DE";
    });
  assert(fieldOf(o.fields, "email") == "ada@example.org");
  assert(fieldOf(o.fields, "phone") == "+493012345");
  assert(fieldOf(o.fields, "country") == "DE" && fieldOf(o.fields, "status") == "active");
  assert(fieldOf(o.fields, "countryName") == "Germany" && !hasField(o.fields, "fax"));
  assert(o.changedFields == 7 && o.changes.length == 7);

  auto none = engine.apply([trim, lower], [FieldValue("email", "a@b.de")]);
  assert(!none.changed && none.fields == [FieldValue("email", "a@b.de")]);
  assert(!hasField(engine.apply([trim], []).fields, "email"));
}
