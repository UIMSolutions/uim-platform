module uim.platform.authorization.domain.services.policy_evaluator;

import std.algorithm.searching : canFind;
import std.array : split;
import std.string : strip, toLower;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class PolicyEvaluator {
  bool resourceMatches(string policyResource, string requestedResource) const {
    if (policyResource == "*") return true;
    return policyResource == requestedResource;
  }

  bool actionMatches(string policyAction, string requestedAction) const {
    if (policyAction == "*") return true;
    return toLower(policyAction) == toLower(requestedAction);
  }

  bool conditionsMatch(PolicyCondition[] conditions, string[string] attributes) const {
    foreach (c; conditions) {
      if (!conditionMatches(c, attributes)) {
        return false;
      }
    }
    return true;
  }

  private bool conditionMatches(PolicyCondition c, string[string] attributes) const {
    auto attr = c.attribute.strip;
    if (!(attr in attributes)) {
      return false;
    }

    auto actual = attributes[attr].strip;
    auto expected = c.value.strip;
    auto op = toLower(c.op.strip);

    switch (op) {
      case "eq":
      case "==":
        return actual == expected;
      case "neq":
      case "!=":
        return actual != expected;
      case "contains":
        return canFind(actual, expected);
      case "in":
        auto options = expected.split(",");
        foreach (o; options) {
          if (actual == o.strip) return true;
        }
        return false;
      default:
        return false;
    }
  }
}
