/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the rule catalogs.
module uim.platform.data_quality.ports.usecases.rules;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IManageValidationRules {
  ValidationRule createValidationRule(CreateValidationRuleRequest r);
  ValidationRule updateValidationRule(UpdateValidationRuleRequest r);
  ValidationRule getValidationRule(TenantId t, ValidationRuleId id);
  /// Ordered by priority, then name.
  ValidationRule[] listValidationRules(TenantId t);
  /// Active rules applying to a dataset, in execution order.
  ValidationRule[] applicableValidationRules(TenantId t, DatasetId ds);
  void deleteValidationRule(TenantId t, ValidationRuleId id);
}

interface IManageCleansingRules {
  CleansingRule createCleansingRule(CreateCleansingRuleRequest r);
  CleansingRule updateCleansingRule(UpdateCleansingRuleRequest r);
  CleansingRule getCleansingRule(TenantId t, CleansingRuleId id);
  CleansingRule[] listCleansingRules(TenantId t);
  CleansingRule[] applicableCleansingRules(TenantId t, DatasetId ds);
  void deleteCleansingRule(TenantId t, CleansingRuleId id);
}
