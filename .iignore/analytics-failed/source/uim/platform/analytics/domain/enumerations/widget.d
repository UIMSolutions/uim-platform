module uim.platform.analytics.domain.enumerations.widget;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
enum FilterOperator {
  // Used for exact matches, where the value must be equal to the specified criteria
  Equals,
  // Used for non-exact matches, where the value must not be equal to the specified criteria
  NotEquals,
  // Used for greater than comparisons, where the value must be greater than the specified criteria
  GreaterThan,
  // Used for less than comparisons, where the value must be less than the specified criteria
  LessThan,
  // Used for range comparisons, where the value must be between two specified criteria (inclusive or exclusive based on implementation)
  Between,
  // Used for membership comparisons, where the value must be one of a specified set of criteria
  In,
  // Used for non-membership comparisons, where the value must not be one of a specified set of criteria
  NotIn,
  // Used for string containment comparisons, where the value must contain a specified substring
  Contains,
  // Used for null checks, where the value must be null or not null based on the operator
  IsNull,
  // Used for not null checks, where the value must not be null
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