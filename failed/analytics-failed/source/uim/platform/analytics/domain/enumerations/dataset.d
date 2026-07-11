/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.enumerations.dataset;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// Defines the role of a column in a dataset. This is used for categorizing columns and determining how they are used in analysis and reporting.
enum ColumnRole {
  /// Used for grouping and filtering data
  dimension,
  /// Used for aggregation and calculations
  measure,
  /// Used for descriptive information that doesn't fit into dimension or measure
  attribute,
}

ColumnRole toColumnRole(string value) {
  mixin(EnumSwitch("ColumnRole", "dimension"));
}
ColumnRole[] toColumnRoles(string[] values) {
  return values.map!(toColumnRole).array;
}
string toString(ColumnRole role) {
  return role.to!string;
}
string[] toString(ColumnRole[] roles) {
  return roles.map!(toString).array;
}
///
unittest {
  assert(ColumnRole.dimension.to!string == "dimension");
  assert(ColumnRole.measure.to!string == "measure");
  assert(ColumnRole.attribute.to!string == "attribute");

  assert("dimension".to!ColumnRole == ColumnRole.dimension);
  assert("measure".to!ColumnRole == ColumnRole.measure);
  assert("attribute".to!ColumnRole == ColumnRole.attribute);

  assert("dimension".toColumnRole == ColumnRole.dimension);
  assert("measure".toColumnRole == ColumnRole.measure);
  assert("attribute".toColumnRole == ColumnRole.attribute);
  assert("noexists".toColumnRole == ColumnRole.dimension); // Default case
  assert("".toColumnRole == ColumnRole.dimension); // Default case

  assert(toString(ColumnRole.dimension) == "dimension");
  assert(toString(ColumnRole.measure) == "measure");
  assert(toString(ColumnRole.attribute) == "attribute");

  assert(["dimension", "measure", "attribute"].toColumnRoles ==
         [ColumnRole.dimension, ColumnRole.measure, ColumnRole.attribute]);
  assert(toString([ColumnRole.dimension, ColumnRole.measure, ColumnRole.attribute]) ==
         ["dimension", "measure", "attribute"]);
}

/// Defines the data type of a column in a dataset. This is used for validation, formatting, and processing of the data.
enum ColumnDataType : string {
  string_ = "string", // Used for textual data
  integer = "integer",  // Used for whole numbers
  decimal = "decimal", // Used for numbers with fractional parts
  date = "date", // Used for calendar dates
  datetime = "datetime", // Used for timestamps with date and time
  boolean = "boolean", // Used for true/false values
}

ColumnDataType toColumnDataType(string type) {
  switch (type.toLower) {
    case "string": return ColumnDataType.string_;
    case "integer": return ColumnDataType.integer;
    case "decimal": return ColumnDataType.decimal;
    case "date": return ColumnDataType.date;
    case "datetime": return ColumnDataType.datetime;
    case "boolean": return ColumnDataType.boolean;
    default: return ColumnDataType.string_; // Default to string if unknown
  }
}

ColumnDataType[] toColumnDataTypes(string[] values) {
  return values.map!(toColumnDataType).array;
}

string toString(ColumnDataType type) {
  return cast(string)type;
}

string[] toString(ColumnDataType[] types) {
  return types.map!(toString).array;
}

///
unittest {
  assert(ColumnDataType.string_.to!string == "string");
  assert(ColumnDataType.integer.to!string == "integer");
  assert(ColumnDataType.decimal.to!string == "decimal");
  assert(ColumnDataType.date.to!string == "date");
  assert(ColumnDataType.datetime.to!string == "datetime");
  assert(ColumnDataType.boolean.to!string == "boolean");

  assert("string".to!ColumnDataType == ColumnDataType.string_);
  assert("integer".to!ColumnDataType == ColumnDataType.integer);
  assert("decimal".to!ColumnDataType == ColumnDataType.decimal);
  assert("date".to!ColumnDataType == ColumnDataType.date);
  assert("datetime".to!ColumnDataType == ColumnDataType.datetime);
  assert("boolean".to!ColumnDataType == ColumnDataType.boolean);

  assert("string".toColumnDataType == ColumnDataType.string_);
  assert("integer".toColumnDataType == ColumnDataType.integer);
  assert("decimal".toColumnDataType == ColumnDataType.decimal);
  assert("date".toColumnDataType == ColumnDataType.date);
  assert("datetime".toColumnDataType == ColumnDataType.datetime);
  assert("boolean".toColumnDataType == ColumnDataType.boolean);
  assert("noexists".toColumnDataType == ColumnDataType.string_); // Default case
  assert("".toColumnDataType == ColumnDataType.string_); // Default case

  assert(toString(ColumnDataType.string_) == "string");
  assert(toString(ColumnDataType.integer) == "integer");
  assert(toString(ColumnDataType.decimal) == "decimal");
  assert(toString(ColumnDataType.date) == "date");
  assert(toString(ColumnDataType.datetime) == "datetime");
  assert(toString(ColumnDataType.boolean) == "boolean");

  assert(["string", "integer", "decimal", "date", "datetime", "boolean"].toColumnDataTypes ==
         [ColumnDataType.string_, ColumnDataType.integer, ColumnDataType.decimal, ColumnDataType.date, ColumnDataType.datetime, ColumnDataType.boolean]);
  assert(toString([ColumnDataType.string_, ColumnDataType.integer, ColumnDataType.decimal, ColumnDataType.date, ColumnDataType.datetime, ColumnDataType.boolean]) ==
         ["string", "integer", "decimal", "date", "datetime", "boolean"]);
}