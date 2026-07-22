/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.enumerations.widget;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

enum FilterOperator : string {
  // Used for exact matches, where the value must be equal to the specified criteria
  equals = "equals",
  // Used for non-exact matches, where the value must not be equal to the specified criteria
  notEquals = "notEquals",
  // Used for greater than comparisons, where the value must be greater than the specified criteria
  greaterThan = "greaterThan",
  // Used for less than comparisons, where the value must be less than the specified criteria
  lessThan = "lessThan",
  // Used for range comparisons, where the value must be between two specified criteria (inclusive or exclusive based on implementation)
  between = "between",
  // Used for membership comparisons, where the value must be one of a specified set of criteria
  in_ = "in",
  // Used for non-membership comparisons, where the value must not be one of a specified set of criteria
  notIn = "notIn",
  // Used for string containment comparisons, where the value must contain a specified substring
  contains = "contains",
  // Used for null checks, where the value must be null or not null based on the operator
  isNull = "isNull",
  // Used for not null checks, where the value must not be null
  isNotNull = "isNotNull",
}
FilterOperator toFilterOperator(string operator) {
  switch (operator.toLower()) {
    case "equals": return FilterOperator.equals;
    case "notequals": return FilterOperator.notEquals;
    case "greaterthan": return FilterOperator.greaterThan;
    case "lessthan": return FilterOperator.lessThan;
    case "between": return FilterOperator.between;
    case "in": return FilterOperator.in_;
    case "notin": return FilterOperator.notIn;
    case "contains": return FilterOperator.contains;
    case "isnull": return FilterOperator.isNull;
    case "isnotnull": return FilterOperator.isNotNull;
    default: throw new Exception("Invalid filter operator: " ~ operator);
  }
}
FilterOperator[] toFilterOperator(string[] operators) {
  return operators.map!(toFilterOperator).array;
}
string toString(FilterOperator operator) {
  return cast(string)operator; // This will return the enum member name as a string,
}
string[] toStrings(FilterOperator[] operators) {
  return operators.map!toString.array;
}
///
unittest {
  assert("equals".toFilterOperator == FilterOperator.equals);
  assert("notEquals".toFilterOperator == FilterOperator.notEquals);
  assert("greaterThan".toFilterOperator == FilterOperator.greaterThan);
  assert("lessThan".toFilterOperator == FilterOperator.lessThan);
  assert("between".toFilterOperator == FilterOperator.between);
  assert("in".toFilterOperator == FilterOperator.in_);
  assert("notIn".toFilterOperator == FilterOperator.notIn);
  assert("contains".toFilterOperator == FilterOperator.contains);
  assert("isNull".toFilterOperator == FilterOperator.isNull);
  assert("isNotNull".toFilterOperator == FilterOperator.isNotNull);

  assert(FilterOperator.equals.toString == "equals");
  assert(FilterOperator.notEquals.toString == "notEquals");
  assert(FilterOperator.greaterThan.toString == "greaterThan");
  assert(FilterOperator.lessThan.toString == "lessThan");
  assert(FilterOperator.between.toString == "between");
  assert(FilterOperator.in_.toString == "in");
  assert(FilterOperator.notIn.toString == "notIn");
  assert(FilterOperator.contains.toString == "contains");
  assert(FilterOperator.isNull.toString == "isNull");
  assert(FilterOperator.isNotNull.toString == "isNotNull");

  assert(toFilterOperator(["equals", "notEquals", "greaterThan", "lessThan"]) == [FilterOperator.equals, FilterOperator.notEquals, FilterOperator.greaterThan, FilterOperator.lessThan]);
  assert(toStrings([FilterOperator.equals, FilterOperator.notEquals, FilterOperator.greaterThan, FilterOperator.lessThan]) == ["equals", "notEquals", "greaterThan", "lessThan"]);
}