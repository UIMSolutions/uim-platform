/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.services.retention_evaluator;

// import uim.platform.logging.domain.entities.retention_policy;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct RetentionValidation {
  bool valid;
  string[] errors;
}

struct RetentionEvaluator {
  static RetentionValidation validate(const ref RetentionPolicy policy) {
    string[] errors;

    if (policy.name.length == 0)
      errors ~= "Policy name is required";
    if (policy.retentionDays < 1)
      errors ~= "Retention days must be at least 1";
    if (policy.retentionDays > 365)
      errors ~= "Retention days must not exceed 365";
    if (policy.maxSizeGB <= 0)
      errors ~= "Max size must be positive";

    return RetentionValidation(errors.length == 0, errors);
  }

  static long computeCutoffTimestamp(int retentionDays, long nowSeconds) {
    return nowSeconds - (retentionDays * 86_400);
  }
}
