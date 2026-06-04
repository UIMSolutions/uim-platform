module uim.platform.analytics.domain.enumerations.dataset;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
enum ColumnRole {
  Dimension,
  Measure,
  Attribute,
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
  String,
  Integer,
  Decimal,
  Date,
  DateTime,
  Boolean,
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