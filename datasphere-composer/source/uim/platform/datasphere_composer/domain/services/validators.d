/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.services.validators;

import uim.platform.datasphere_composer;
mixin(ShowModule!());

@safe:

struct ComposerValidator {
  static string validateDataProvider(DataProvider provider) {
    if (provider.name.isEmpty) return "Provider name is required";
    if (provider.systemType.length == 0) return "System type is required";
    return null;
  }

  static string validateDataProduct(DataProduct product) {
    if (product.name.isEmpty) return "Data product name is required";
    if (product.providerId.value.length == 0) return "Provider ID is required";
    return null;
  }

  static string validateUnificationRule(UnificationRule rule) {
    if (rule.name.isEmpty) return "Rule name is required";
    if (rule.identifierAttributes.length == 0) return "At least one identifier attribute is required";
    if (rule.identifierAttributes.length > 5) return "Maximum 5 identifier attributes per rule";
    return null;
  }

  static string validateDataSourceConfig(DataSourceConfig config) {
    if (config.dataProductId.value.length == 0) return "Data product ID is required";
    if (config.providerId.value.length == 0) return "Provider ID is required";
    return null;
  }

  static string validateAttributeMapping(AttributeMapping mapping) {
    if (mapping.sourceAttributename.isEmpty) return "Source attribute name is required";
    if (mapping.targetAttributename.isEmpty) return "Target attribute name is required";
    if (mapping.configId.value.length == 0) return "Data source config ID is required";
    return null;
  }

  static string validateTenantUser(TenantUser user) {
    if (user.email.length == 0) return "User email is required";
    return null;
  }
}
