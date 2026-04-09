/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.validate_data;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.validation_rule;
// import uim.platform.data.quality.domain.entities.validation_result;
// import uim.platform.data.quality.domain.ports.repositories.validation_rules;
// import uim.platform.data.quality.domain.ports.repositories.validation_results;
// import uim.platform.data.quality.domain.services.validation_engine;
// import uim.platform.data.quality.application.dto;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class ValidateDataUseCase : UIMUseCase {
  private ValidationRuleRepository ruleRepo;
  private ValidationResultRepository resultRepo;
  private ValidationEngine engine;

  this(ValidationRuleRepository ruleRepo, ValidationResultRepository resultRepo,
      ValidationEngine engine) {
    this.ruleRepo = ruleRepo;
    this.resultRepo = resultRepo;
    this.engine = engine;
  }

  /// Validate a single record against active rules.
  ValidationResult validateRecord(ValidateRecordRequest req) {
    auto rules = ruleRepo.findActive(req.tenantId);
    auto result = engine.validate(req.recordId, req.tenantId, req.datasetId,
        req.fieldValues, rules);
    resultRepo.save(result);
    return result;
  }

  /// Validate a batch of records.
  ValidationResult[] validateBatch(ValidateBatchRequest req) {
    auto rules = ruleRepo.findActive(req.tenantId);
    ValidationResult[] results;

    foreach (ref rec; req.records) {
      auto result = engine.validate(rec.recordId, req.tenantId, req.datasetId,
          rec.fieldValues, rules);
      resultRepo.save(result);
      results ~= result;
    }

    return results;
  }

  /// Retrieve validation results for a dataset.
  ValidationResult[] getResultsByDataset(TenantId tenantId, DatasetId datasetId) {
    return resultRepo.findByDataset(tenantId, datasetId);
  }

  /// Retrieve validation result for a single record.
  ValidationResult* getResultByRecord(RecordId recordtenantId, id tenantId) {
    return resultRepo.findByRecord(recordtenantId, id);
  }
}
