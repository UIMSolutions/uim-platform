/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// One extracted value of a document: a header field (rowIndex 0) or a
/// cell of a line item (rowIndex 1..n). Corrections keep the original value.
module uim.platform.document_ai.domain.entities.extracted_field;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct ExtractedField {
  mixin TenantEntity!ExtractedFieldId;

  DocumentId documentId;
  SchemaFieldId schemaFieldId;
  FieldScope fieldScope = FieldScope.header;
  int rowIndex; /// 0 = header, 1.. = line item
  int sequenceNumber;
  string name;
  string label;
  FieldValueType valueType = FieldValueType.text;
  bool required;
  string value;
  string originalValue; /// the extracted value before the first correction
  double confidence = 0; /// 0 … 1
  int page = 1;
  string coordinates; /// "x,y,width,height" relative to the page (0 … 1)
  bool corrected;
  string correctedBy;

  /// Replace the value (validated against the type); confidence becomes 1.
  void correct(string newValue, string by) {
    auto v = newValue.strip;
    if (v.length)
      checkFieldValue(valueType, v, "Value of '" ~ name ~ "'");
    if (!corrected)
      originalValue = value;
    value = v;
    corrected = true;
    correctedBy = by;
    confidence = 1.0;
  }

  bool isMissing() const {
    return required && value.strip.length == 0;
  }
}

///
unittest {
  ExtractedField f;
  f.name = "grossAmount";
  f.valueType = FieldValueType.number;
  f.value = "100.00";
  f.confidence = 0.4;
  f.correct("120.50", "ada");
  assert(f.corrected && f.originalValue == "100.00" && f.value == "120.50" && f.confidence == 1.0);
  f.correct("121", "bob");
  assert(f.originalValue == "100.00" && f.correctedBy == "bob");
  assert(failsWith(DaiErrorKind.invalid, () { f.correct("lots", "ada"); }));
  f.required = true;
  f.value = "";
  assert(f.isMissing);
}
