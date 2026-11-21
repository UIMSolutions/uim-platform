/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: standardizes postal addresses without external
/// reference data —
///   1. white space trimmed and collapsed
///   2. country names (English, German, French, local) → ISO 3166 alpha-2
///   3. city and region title cased
///   4. postal code normalized for the country (DE/US compact, GB/NL/CA spaced)
///   5. street abbreviations expanded (Str. → Straße for DE/AT/CH, St. → Street, …)
///   6. quality: verified / corrected (complete and the postal code fits the
///      country's format), invalid (it does not), partial, unverifiable
module uim.platform.data_quality.domain.services.address_cleanser;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class AddressCleanser {
  AddressOutcome cleanse(const AddressInput input) {
    AddressOutcome o;
    o.line1 = collapseWhitespace(input.line1);
    o.line2 = collapseWhitespace(input.line2);
    o.city = collapseWhitespace(input.city);
    o.region = collapseWhitespace(input.region);
    o.postalCode = collapseWhitespace(input.postalCode).toUpper;
    o.country = collapseWhitespace(input.country);
    if (o.line1 != input.line1 || o.line2 != input.line2 || o.city != input.city || o.region != input.region
      || o.country != input.country || collapseWhitespace(input.postalCode) != input.postalCode)
      o.changes ~= "Trimmed white space";

    auto iso = countryCode(o.country);
    if (iso.length) {
      o.countryRecognized = true;
      if (iso != o.country)
        o.changes ~= "Country '" ~ o.country ~ "' → " ~ iso;
      o.country = iso;
    }

    auto city = titleCase(o.city);
    if (city != o.city) {
      o.city = city;
      o.changes ~= "Normalized city case";
    }
    auto region = o.region.length <= 3 ? o.region.toUpper : titleCase(o.region); // "ca", "BY" stay codes
    if (region != o.region) {
      o.region = region;
      o.changes ~= "Normalized region case";
    }

    auto postal = normalizePostalCode(o.postalCode, o.country);
    if (postal != o.postalCode || postal != input.postalCode.strip) {
      if (postal != input.postalCode.strip)
        o.changes ~= "Postal code '" ~ input.postalCode.strip ~ "' → '" ~ postal ~ "'";
      o.postalCode = postal;
    }

    auto street = expandAbbreviations(o.line1, o.country);
    if (street != o.line1) {
      o.line1 = street;
      o.changes ~= "Expanded street abbreviations";
    }

    o.postalCodePlausible = o.postalCode.length > 0 && postalCodeFits(o.country, o.postalCode);
    auto complete = o.line1.length && o.city.length && o.postalCode.length && o.country.length;
    if (complete && o.countryRecognized && knowsPostalFormat(o.country) && !o.postalCodePlausible)
      o.quality = AddressQuality.invalid;
    else if (complete && o.countryRecognized)
      o.quality = o.changes.length == 0 ? AddressQuality.verified : AddressQuality.corrected;
    else if (o.line1.length && o.city.length)
      o.quality = AddressQuality.partial;
    else
      o.quality = AddressQuality.unverifiable;
    return o;
  }
}

/// Country name or code → ISO 3166 alpha-2 ("" if unknown).
string countryCode(string country) {
  auto key = normalizeForMatch(country).replace(" ", "");
  if (key.length == 0)
    return "";
  if (auto code = key in countryNames)
    return *code;
  return "";
}

private immutable string[string] countryNames;

shared static this() {
  string[string] m;
  void add(string iso, string[] names...) {
    m[iso.toLower] = iso;
    foreach (n; names)
      m[normalizeForMatch(n).replace(" ", "")] = iso;
  }

  add("DE", "Germany", "Deutschland", "Allemagne", "DEU", "BRD");
  add("AT", "Austria", "Österreich", "Oesterreich", "Autriche", "AUT");
  add("CH", "Switzerland", "Schweiz", "Suisse", "Svizzera", "CHE");
  add("FR", "France", "Frankreich", "FRA");
  add("IT", "Italy", "Italien", "Italia", "ITA");
  add("ES", "Spain", "Spanien", "España", "Espana", "ESP");
  add("PT", "Portugal", "PRT");
  add("NL", "Netherlands", "Niederlande", "Holland", "Nederland", "The Netherlands", "NLD");
  add("BE", "Belgium", "Belgien", "Belgique", "België", "BEL");
  add("LU", "Luxembourg", "Luxemburg", "LUX");
  add("DK", "Denmark", "Dänemark", "Danmark", "DNK");
  add("SE", "Sweden", "Schweden", "Sverige", "SWE");
  add("NO", "Norway", "Norwegen", "Norge", "NOR");
  add("FI", "Finland", "Finnland", "Suomi", "FIN");
  add("PL", "Poland", "Polen", "Polska", "POL");
  add("CZ", "Czech Republic", "Czechia", "Tschechien", "Česko", "CZE");
  add("HU", "Hungary", "Ungarn", "Magyarország", "HUN");
  add("GR", "Greece", "Griechenland", "GRC");
  add("TR", "Turkey", "Türkiye", "Türkei", "Turkiye", "TUR");
  add("IE", "Ireland", "Irland", "IRL");
  add("GB", "United Kingdom", "UK", "Great Britain", "Großbritannien", "England", "Scotland", "Wales", "GBR");
  add("US", "United States", "United States of America", "USA", "U.S.A.", "U.S.", "America", "Vereinigte Staaten");
  add("CA", "Canada", "Kanada", "CAN");
  add("MX", "Mexico", "Mexiko", "México", "MEX");
  add("BR", "Brazil", "Brasilien", "Brasil", "BRA");
  add("AR", "Argentina", "Argentinien", "ARG");
  add("AU", "Australia", "Australien", "AUS");
  add("NZ", "New Zealand", "Neuseeland", "NZL");
  add("JP", "Japan", "JPN");
  add("CN", "China", "CHN", "People's Republic of China");
  add("IN", "India", "Indien", "IND");
  add("KR", "South Korea", "Südkorea", "Korea", "KOR");
  add("SG", "Singapore", "Singapur", "SGP");
  add("ZA", "South Africa", "Südafrika", "ZAF");
  add("AE", "United Arab Emirates", "Vereinigte Arabische Emirate", "UAE", "ARE");
  add("RU", "Russia", "Russland", "Russian Federation", "RUS");
  add("UA", "Ukraine", "UKR");
  countryNames = (() @trusted => cast(immutable) m)();
}

/// Postal code shapes per country ('9' digit, 'A' letter, other literal).
private immutable string[][string] postalFormats;

shared static this() {
  string[][string] f;
  f["DE"] = ["99999"];
  f["FR"] = ["99999"];
  f["IT"] = ["99999"];
  f["ES"] = ["99999"];
  f["FI"] = ["99999"];
  f["US"] = ["99999", "99999-9999"];
  f["AT"] = ["9999"];
  f["CH"] = ["9999"];
  f["BE"] = ["9999"];
  f["DK"] = ["9999"];
  f["NO"] = ["9999"];
  f["LU"] = ["9999"];
  f["AU"] = ["9999"];
  f["NZ"] = ["9999"];
  f["ZA"] = ["9999"];
  f["HU"] = ["9999"];
  f["NL"] = ["9999 AA"];
  f["PL"] = ["99-999"];
  f["PT"] = ["9999-999"];
  f["SE"] = ["999 99"];
  f["CZ"] = ["999 99"];
  f["GR"] = ["999 99"];
  f["CA"] = ["A9A 9A9"];
  f["JP"] = ["999-9999"];
  f["BR"] = ["99999-999"];
  f["IN"] = ["999999"];
  f["CN"] = ["999999"];
  f["RU"] = ["999999"];
  f["SG"] = ["999999"];
  f["GB"] = ["A9 9AA", "A99 9AA", "AA9 9AA", "AA99 9AA", "A9A 9AA", "AA9A 9AA"];
  postalFormats = (() @trusted => cast(immutable) f)();
}

bool knowsPostalFormat(string iso) {
  return (iso in postalFormats) !is null;
}

/// True if the code fits one of the country's shapes (unknown countries: any code).
bool postalCodeFits(string iso, string code) {
  auto formats = iso in postalFormats;
  if (formats is null)
    return code.length > 0;
  foreach (shape; *formats)
    if (fitsShape(shape, code))
      return true;
  return false;
}

private bool fitsShape(string shape, string code) pure {
  if (shape.length != code.length)
    return false;
  foreach (i, s; shape) {
    auto c = code[i];
    if (s == '9' && !(c >= '0' && c <= '9'))
      return false;
    if (s == 'A' && !(c >= 'A' && c <= 'Z'))
      return false;
    if (s != '9' && s != 'A' && s != c)
      return false;
  }
  return true;
}

/// Canonical spacing of a postal code for the country.
string normalizePostalCode(string code, string iso) {
  auto compact = code.replace(" ", "").replace("-", "").toUpper;
  switch (iso) {
  case "DE", "FR", "IT", "ES", "FI", "AT", "CH", "BE", "DK", "NO", "LU", "AU", "NZ", "ZA", "HU", "IN", "CN", "RU", "SG":
    if (iso == "DE" && compact.length == 4 && compact.all!(c => c >= '0' && c <= '9'))
      compact = "0" ~ compact; // leading zero lost in spreadsheets
    return compact;
  case "US":
    return compact.length == 9 ? compact[0 .. 5] ~ "-" ~ compact[5 .. $] : compact;
  case "NL":
    return compact.length == 6 ? compact[0 .. 4] ~ " " ~ compact[4 .. $] : compact;
  case "PL":
    return compact.length == 5 ? compact[0 .. 2] ~ "-" ~ compact[2 .. $] : compact;
  case "PT":
    return compact.length == 7 ? compact[0 .. 4] ~ "-" ~ compact[4 .. $] : compact;
  case "SE", "CZ", "GR":
    return compact.length == 5 ? compact[0 .. 3] ~ " " ~ compact[3 .. $] : compact;
  case "JP":
    return compact.length == 7 ? compact[0 .. 3] ~ "-" ~ compact[3 .. $] : compact;
  case "BR":
    return compact.length == 8 ? compact[0 .. 5] ~ "-" ~ compact[5 .. $] : compact;
  case "GB", "CA":
    return compact.length >= 5 ? compact[0 .. $ - 3] ~ " " ~ compact[$ - 3 .. $] : compact;
  default:
    return code.strip.toUpper;
  }
}

// Street abbreviation patterns, compiled once per thread.
private Regex!char germanStreet, germanPlatz;
private Regex!char[] englishPatterns;
private string[] englishExpansions;

static this() @trusted {
  germanStreet = regex(`([Ss])tr\.(\s|$)`);
  germanPlatz = regex(`\bPl\.(\s|$)`);
  static immutable string[2][] english = [
    ["St", "Street"], ["Str", "Street"], ["Ave", "Avenue"], ["Av", "Avenue"], ["Blvd", "Boulevard"],
    ["Rd", "Road"], ["Ln", "Lane"], ["Dr", "Drive"], ["Ct", "Court"], ["Pl", "Place"], ["Sq", "Square"],
    ["Hwy", "Highway"], ["Pkwy", "Parkway"], ["Apt", "Apartment"], ["Ste", "Suite"], ["Fl", "Floor"]
  ];
  foreach (pair; english) {
    englishPatterns ~= regex(`\b` ~ pair[0] ~ `\.?(?=[\s,]|$)`);
    englishExpansions ~= pair[1];
  }
}

/// Expand common street abbreviations (word aware).
string expandAbbreviations(string line, string iso) @trusted {
  if (line.length == 0)
    return line;
  string result = line;
  if (iso == "DE" || iso == "AT" || iso == "CH") {
    // "Hauptstr. 5" → "Hauptstraße 5", "Berliner Str. 1" → "Berliner Straße 1"
    result = replaceAll(result, germanStreet, "$1traße$2");
    result = replaceAll(result, germanPlatz, "Platz$1");
  } else
    foreach (i, re; englishPatterns)
      result = replaceAll(result, re, englishExpansions[i]);
  return result;
}

///
unittest {
  auto c = new AddressCleanser;
  auto o = c.cleanse(AddressInput("  Hauptstr.  5 ", "", "münchen", "bayern", "8033", "Deutschland"));
  assert(o.line1 == "Hauptstraße 5" && o.city == "München" && o.region == "Bayern", o.line1);
  assert(o.country == "DE" && o.postalCode == "08033" && o.quality == AddressQuality.corrected);

  auto ok = c.cleanse(AddressInput("10 Downing Street", "", "London", "", "SW1A 2AA", "GB"));
  assert(ok.quality == AddressQuality.verified && ok.changes.length == 0, ok.changes.join("; "));

  auto us = c.cleanse(AddressInput("1600 Pennsylvania Ave NW", "", "washington", "dc", "205000001", "USA"));
  assert(us.line1 == "1600 Pennsylvania Avenue NW" && us.postalCode == "20500-0001" && us.region == "DC" && us.country == "US");

  auto bad = c.cleanse(AddressInput("Rue de Rivoli 1", "", "Paris", "", "7500", "France"));
  assert(bad.quality == AddressQuality.invalid);
  assert(c.cleanse(AddressInput("Somewhere 1", "", "Town", "", "", "")).quality == AddressQuality.partial);
  assert(c.cleanse(AddressInput("", "", "", "", "", "")).quality == AddressQuality.unverifiable);
  assert(countryCode("Österreich") == "AT" && countryCode("u.s.a.") == "US" && countryCode("Atlantis") == "");
  assert(postalCodeFits("NL", "1012 AB") && !postalCodeFits("NL", "1012AB") && postalCodeFits("XX", "abc"));
}
