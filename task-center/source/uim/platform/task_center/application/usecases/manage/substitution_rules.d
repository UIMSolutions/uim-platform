/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.substitution_rules;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

    /// Substitution Rule Management 
class ManageSubstitutionRulesUseCase { // TODO: UIMUseCase {
    private SubstitutionRuleRepository repo;

    this(SubstitutionRuleRepository repo) {
        this.repo = repo;
    }

    /** 
        * Substitution Rule Management Use Case
        * This use case provides methods to manage substitution rules, including creating, updating, activating, deactivating, and deleting substitution rules. It also provides methods to retrieve substitution rules based on different criteria such as user, substitute, and status.
        */
    SubstitutionRule getSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        return repo.findById(tenantId, id);
    }

    SubstitutionRule[] listSubstitutionRulesByUser(TenantId tenantId, UserId userId) {
        return repo.findByUser(tenantId, userId);
    }

    SubstitutionRule[] listSubstitutionRulesBySubstitute(TenantId tenantId, UserId substituteId) {
        return repo.findBySubstitute(tenantId, substituteId);
    }

    SubstitutionRule[] listSubstitutionRules(TenantId tenantId, SubstitutionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    /** 
        * Create Substitution Rule
        * This method creates a new substitution rule based on the provided request. It initializes the rule with the request data and saves it to the repository.
        */
    CommandResult createSubstitutionRule(CreateSubstitutionRuleRequest req) {
        auto rule = SubstitutionRule(req.tenantId);
        rule.id = req.ruleId;
        rule.userId = req.userId;
        rule.substituteId = req.substituteId;
        rule.definitionId = req.definitionId;
        // TODO: rule.startDate = req.startDate;
        // TODO: rule.endDate = req.endDate;
        rule.isAutoForward = req.isAutoForward;
        rule.createdBy = req.createdBy;

        repo.save(rule);
        return CommandResult(true, rule.id.value, "");
    }

    /** 
        * Update Substitution Rule
        * This method updates an existing substitution rule based on the provided request. It modifies the rule with the request data and saves the changes to the repository.
        */
    CommandResult updateSubstitutionRule(UpdateSubstitutionRuleRequest req) {
        auto existing = repo.findById(req.tenantId, req.ruleId);
        if (existing.isNull)
            return CommandResult(false, "", "Substitution rule not found");

        if (!req.substituteId.isEmpty) existing.substituteId = req.substituteId;
        if (!req.definitionId.isEmpty) existing.definitionId = req.definitionId;
        if (req.startDate.length > 0) existing.startDate = req.startDate;
        if (req.endDate.length > 0) existing.endDate = req.endDate;
        existing.isAutoForward = req.isAutoForward;
        existing.updatedBy = req.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    /** 
        * Activate Substitution Rule
        * This method activates an existing substitution rule by setting its status to active. It updates the rule in the repository.
        */
    CommandResult activateSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Substitution rule not found");

        rule.status = SubstitutionStatus.active;
        
        repo.update(rule);
        return CommandResult(true, rule.id.value, "");
    }

    /** 
        * Deactivate Substitution Rule
        * This method deactivates an existing substitution rule by setting its status to inactive. It updates the rule in the repository.
        */
    CommandResult deactivateSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Substitution rule not found");
            
        rule.status = SubstitutionStatus.inactive;

        repo.update(rule);
        return CommandResult(true, rule.id.value, "");
    }

    /** 
        * Delete Substitution Rule
        * This method deletes an existing substitution rule from the repository. It first checks if the rule exists and then removes it.
        * Note: Depending on the business requirements, instead of permanently deleting the rule, we could also consider implementing a soft delete by setting a flag on the rule to indicate that it is deleted, which would allow us to retain the history of substitution rules and potentially restore them if needed.
        * 
        * Additional considerations for deletion:
        * - If there are any active tasks that are currently being substituted based on this rule,
        *   we may want to handle those tasks before deleting the rule, such as reassigning them back to the original user or notifying the substitute user about the change.
        * - We should also consider the implications of deleting a substitution rule on any reporting or auditing features that may rely on the history of substitution rules, and ensure that we have appropriate logging and auditing in place to track the deletion of substitution rules for accountability and troubleshooting purposes.
        * - Finally, we should ensure that we have appropriate access control in place to restrict who can delete substitution rules, as this can have significant implications for task management and user productivity if not handled carefully. 
        * Overall, the deletion of substitution rules should be handled with caution and should take into account the potential impact on active tasks, reporting, auditing, and access control to ensure that we maintain a robust and reliable task management system while also providing flexibility for users to manage their substitution rules effectively.  
        * Note: The actual implementation of the deleteSubstitutionRule method may vary based on the specific requirements and constraints of the application, and it is important to carefully consider the implications of deleting substitution rules in the context of the overall task management system to ensure that we maintain a balance between functionality, usability, and reliability.
        */
    CommandResult deleteSubstitutionRule(TenantId tenantId, SubstitutionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Substitution rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }
}
