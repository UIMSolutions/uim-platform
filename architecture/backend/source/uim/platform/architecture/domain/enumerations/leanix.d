/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// SAP LeanIX fact sheet types (meta model v4) for cross references to the
/// enterprise architecture management tool, and data classifications.
module uim.platform.architecture.domain.enumerations.leanix;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

immutable string[] leanixFactSheetTypes = [
  "Application", "ITComponent", "Interface", "DataObject", "BusinessCapability", "BusinessContext",
  "Organization", "Platform", "Initiative", "Objective", "Provider", "TechCategory"
];

/// Confidentiality of a data building block.
enum DataClassification : string {
  public_ = "public",
  internal = "internal",
  confidential = "confidential",
  restricted = "restricted"
}

/// "" stays "", other values are canonicalized or rejected.
string parseFactSheetType(string text) {
  return text.strip.length == 0 ? "" : parseNamedValue(text, leanixFactSheetTypes, "LeanIX fact sheet type");
}

string parseDataClassification(string text) {
  return text.strip.length == 0 ? "" : cast(string) parseEnumValue!DataClassification(text, "Data classification");
}

///
unittest {
  assert(parseFactSheetType("it-component") == "ITComponent" && parseFactSheetType(" ") == "");
  assert(parseDataClassification("CONFIDENTIAL") == "confidential" && parseDataClassification("public") == "public");
  assert(failsWith(ArchitectureErrorKind.invalid, () { parseDataClassification("secret"); }));
}
