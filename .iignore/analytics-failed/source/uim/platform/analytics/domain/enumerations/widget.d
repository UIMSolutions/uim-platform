module uim.platform.analytics.domain.enumerations.widget;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
enum FilterOperator {
  Equals,
  NotEquals,
  GreaterThan,
  LessThan,
  Between,
  In,
  NotIn,
  Contains,
  IsNull,
  IsNotNull,
}
FilterOperator toFilterOperator(string operator) {
  const map = [
    "equals": FilterOperator.Equals,
    "notequals": FilterOperator.NotEquals,
    "greaterthan": FilterOperator.GreaterThan,
    "lessthan": FilterOperator.LessThan,
    "between": FilterOperator.Between,
    "in": FilterOperator.In,
    "notin": FilterOperator.NotIn,
    "contains": FilterOperator.Contains,
    "isnull": FilterOperator.IsNull,
    "isnotnull": FilterOperator.IsNotNull
  ];
  return map.get(operator.toLower, FilterOperator.Equals);
}