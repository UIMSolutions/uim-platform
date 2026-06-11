module uim.platform.task_center.application.dtos.substitutionrule;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:
struct CreateSubstitutionRuleRequest {
  TenantId tenantId;
  SubstitutionRuleId substitutionRuleId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a substitution rule with the same ID already exists, the service can return the existing rule instead of creating a new one.

  UserId userId; // The user for whom the substitution rule is being created.
  UserId substituteId; // The user who will be the substitute for the original user during the specified period.
  TaskDefinitionId taskDefinitionId;
  Date startDate; // The start date of the substitution period. Tasks with due dates on or after this date will be considered for substitution.
  Date endDate; // The end date of the substitution period. Tasks with due dates on or before this date will be considered for substitution.
  bool isAutoForward; // Indicates whether tasks that fall within the substitution period should be automatically forwarded to the substitute user. If false, the substitution rule will only be used for informational purposes (e.g., showing a message to the original user about who their substitute is), but tasks will not be automatically reassigned.
  UserId createdBy; // The user who is creating the substitution rule. This is important for auditing purposes, as it allows the system to track who created the rule.
}

struct UpdateSubstitutionRuleRequest {
  TenantId tenantId;
  SubstitutionRuleId ruleId; // The ID of the substitution rule to update. This is required to identify which rule to update.
  UserId substituteId; // The user who will be the substitute for the original user during the specified period.
  TaskDefinitionId taskDefinitionId;
  Date startDate; // The start date of the substitution period. Tasks with due dates on or after this date will be considered for substitution.
  Date endDate; // The end date of the substitution period. Tasks with due dates on or before this date will be considered for substitution.
  bool isAutoForward; // Indicates whether tasks that fall within the substitution period should be automatically forwarded to the substitute user. If false, the substitution rule will only be used for informational purposes (e.g., showing a message to the original user about who their substitute is), but tasks will not be automatically reassigned.
  UserId updatedBy; // The user who is performing the update operation. This is important for auditing purposes, as it allows the system to track who made changes to the substitution rule.
}
