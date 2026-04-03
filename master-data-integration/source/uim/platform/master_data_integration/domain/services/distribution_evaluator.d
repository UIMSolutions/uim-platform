module uim.platform.xyz.domain.services.distribution_evaluator;

import domain.entities.distribution_model;
import domain.entities.filter_rule;
import domain.entities.master_data_object;
import domain.types;

/// Domain service: evaluates whether a master data object matches distribution
/// model criteria and filter rules.
class DistributionEvaluator
{
    /// Check if an object's category is covered by the distribution model.
    bool matchesDistribution(DistributionModel model, MasterDataObject obj)
    {
        // Check if the object's category is in the model's scope
        foreach (cat; model.categories)
        {
            if (cat == obj.category)
                return true;
        }
        return false;
    }

    /// Evaluate a single filter condition against an object.
    bool evaluateCondition(FilterCondition cond, MasterDataObject obj)
    {
        auto fieldName = cond.fieldName;
        string value;

        // Check built-in fields first
        switch (fieldName)
        {
            case "objectType":
                value = obj.objectType;
                break;
            case "displayName":
                value = obj.displayName;
                break;
            case "sourceSystem":
                value = obj.sourceSystem;
                break;
            case "localId":
                value = obj.localId;
                break;
            case "globalId":
                value = obj.globalId;
                break;
            default:
                // Look in attributes
                if (auto p = fieldName in obj.attributes)
                    value = *p;
                else
                    value = "";
                break;
        }

        return evaluateOperator(cond.operator, value, cond.value, cond.valueList);
    }

    /// Evaluate a complete filter rule against an object.
    bool matchesFilter(FilterRule rule, MasterDataObject obj)
    {
        if (!rule.isActive)
            return true; // Inactive rules pass everything

        if (rule.conditions.length == 0)
            return true;

        bool isAnd = (rule.logicOperator != "OR");

        foreach (ref cond; rule.conditions)
        {
            bool match = evaluateCondition(cond, obj);
            if (isAnd && !match)
                return false;
            if (!isAnd && match)
                return true;
        }

        return isAnd; // AND: all passed; OR: none matched
    }

    private bool evaluateOperator(FilterOperator op, string value, string expected, string[] list)
    {
        import std.algorithm : canFind;
        import std.string : indexOf;

        final switch (op)
        {
            case FilterOperator.equals:
                return value == expected;
            case FilterOperator.notEquals:
                return value != expected;
            case FilterOperator.contains:
                return value.indexOf(expected) >= 0;
            case FilterOperator.startsWith:
                return value.length >= expected.length && value[0 .. expected.length] == expected;
            case FilterOperator.endsWith:
                return value.length >= expected.length && value[$ - expected.length .. $] == expected;
            case FilterOperator.inList:
                return list.canFind(value);
            case FilterOperator.notInList:
                return !list.canFind(value);
            case FilterOperator.isNull:
                return value.length == 0;
            case FilterOperator.isNotNull:
                return value.length > 0;
            case FilterOperator.greaterThan:
                return value > expected;
            case FilterOperator.lessThan:
                return value < expected;
            case FilterOperator.between:
                return value >= expected && value <= expected; // Simplified
        }
    }
}
