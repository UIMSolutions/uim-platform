module uim.platform.analytics.domain.enumerations.dataset;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
enum ColumnRole {
  Dimension, // Used for grouping and filtering data
  Measure, // Used for aggregation and calculations
  Attribute, // Used for descriptive information that doesn't fit into dimension or measure
}

ColumnRole toColumnRole(string role) {
  const map = [
    "dimension": ColumnRole.Dimension,
    "measure": ColumnRole.Measure,
    "attribute": ColumnRole.Attribute,
  ];
  return map.get(role.toLower, ColumnRole.Dimension);
}

enum ColumnDataType {
  String, // Used for textual data
  Integer,  // Used for whole numbers
  Decimal, // Used for numbers with fractional parts
  Date, // Used for calendar dates
  DateTime, // Used for timestamps with date and time
  Boolean, // Used for true/false values
}

ColumnDataType toColumnDataType(string type) {
  const map = [
    "string": ColumnDataType.String,
    "integer": ColumnDataType.Integer,
    "decimal": ColumnDataType.Decimal,
    "date": ColumnDataType.Date,
    "datetime": ColumnDataType.DateTime,
    "boolean": ColumnDataType.Boolean,
  ];
  return map.get(type.toLower, ColumnDataType.String);
}