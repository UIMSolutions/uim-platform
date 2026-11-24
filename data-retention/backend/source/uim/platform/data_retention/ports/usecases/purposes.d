/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of business purposes, legal grounds and their rules.
module uim.platform.data_retention.ports.usecases.purposes;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageBusinessPurposes : IManageResource!(BusinessPurpose, BusinessPurposeId, BusinessPurposeInput) {
  /// Needs at least one active legal ground with an active residence rule.
  BusinessPurpose activate(TenantId t, BusinessPurposeId id, UserId actor);
  BusinessPurpose deactivate(TenantId t, BusinessPurposeId id, UserId actor);
  /// Keep governing the existing data subjects, accept no new ones.
  BusinessPurpose deprecate(TenantId t, BusinessPurposeId id, UserId actor);
}

/// Deleting a legal ground deletes its rules.
alias IManageLegalGrounds = IManageResource!(LegalGround, LegalGroundId, LegalGroundInput);
/// One residence rule per legal ground.
alias IManageResidenceRules = IManageResource!(ResidenceRule, ResidenceRuleId, ResidenceRuleInput);
/// One retention rule per legal ground.
alias IManageRetentionRules = IManageResource!(RetentionRule, RetentionRuleId, RetentionRuleInput);
