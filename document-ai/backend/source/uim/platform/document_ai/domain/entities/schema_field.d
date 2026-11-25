/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A field of an extraction schema (header field or line item column).
module uim.platform.document_ai.domain.entities.schema_field;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct SchemaField {
  mixin TenantEntity!SchemaFieldId;

  SchemaId schemaId;
  FieldScope fieldScope = FieldScope.header;
  int sequenceNumber = 10;
  string name; /// technical name, unique per schema and scope, e.g. "documentNumber"
  string label;
  FieldValueType valueType = FieldValueType.text;
  bool required;
  string description; /// also the prompt of generative AI extraction
  string defaultValue;
  string format; /// e.g. "YYYY-MM-DD" (documentation; values are ISO)

  void validate() const {
    requireId(id.value, "Field ID");
    requireText(schemaId.value, "Schema");
    requireText(name, "Name");
    requireMaxLength(name, 100, "Name");
    if (!isFieldName(name))
      throw DaiException.invalid("Field name '" ~ name ~ "' must start with a letter and contain letters, digits or '_' only");
    requireMaxLength(label, 200, "Label");
    requireMaxLength(description, 2000, "Description");
    requireRange(sequenceNumber, 0, 100_000, "Sequence");
    if (defaultValue.length)
      checkFieldValue(valueType, defaultValue, "Default value of '" ~ name ~ "'");
  }
}

/// Letter, then letters, digits or '_'.
bool isFieldName(string name) pure {
  import std.ascii : isAlpha, isAlphaNum;

  if (name.length == 0 || !isAlpha(name[0]))
    return false;
  return name.all!(c => isAlphaNum(c) || c == '_');
}

///
unittest {
  SchemaField f;
  f.id = SchemaFieldId("f1");
  f.schemaId = SchemaId("inv");
  f.name = "grossAmount";
  f.valueType = FieldValueType.number;
  f.validate();
  f.defaultValue = "abc";
  assert(failsWith(DaiErrorKind.invalid, () { f.validate(); }));
  assert(isFieldName("a_1") && !isFieldName("1a") && !isFieldName("a-b"));
}
