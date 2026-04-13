/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.services.health_checker;

// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Result of validating a health check configuration.
struct ValidationResult {
  bool valid;
  string[] errors;
}

/// Domain service: validates health check configurations.
struct HealthChecker {
  /// Validate a health check configuration for correctness.
  static ValidationResult validate(const ref HealthCheck check) {
    string[] errors;

    if (check.name.length == 0)
      errors ~= "Check name is required";

    if (check.resourceId.value.isEmpty)
      errors ~= "Resource ID is required";

    if (check.intervalSeconds < 10)
      errors ~= "Interval must be at least 10 seconds";

    if (check.intervalSeconds > 86400)
      errors ~= "Interval must not exceed 86400 seconds (24 hours)";

    final switch (check.checkType) {
    case CheckType.availability:
      if (check.url.length == 0)
        errors ~= "URL is required for availability checks";
      break;

    case CheckType.jmx:
      if (check.mbeanName.length == 0)
        errors ~= "MBean name is required for JMX checks";
      if (check.mbeanAttribute.length == 0)
        errors ~= "MBean attribute is required for JMX checks";
      break;

    case CheckType.customHttp:
      if (check.customUrl.length == 0)
        errors ~= "Custom URL is required for custom HTTP checks";
      break;

    case CheckType.process:
      break;

    case CheckType.database:
      break;

    case CheckType.certificate:
      if (check.url.length == 0)
        errors ~= "URL is required for certificate checks";
      break;
    }

    return ValidationResult(errors.length == 0, errors);
  }
}
