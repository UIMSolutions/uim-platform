/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.validate_data;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class ValidateDataUseCase {
  protected IValidationRuleRepository ruleRepo;
  private IValidationResultRepository resultRepo;
  private ValidationEngine engine;

  this(IValidationRuleRepository ruleRepo, IValidationResultRepository resultRepo,
      ValidationEngine engine) {
    this.ruleRepo = ruleRepo;
    this.resultRepo = resultRepo;
    this.engine = engine;
  }

  /// Validate a single record against active rules.
  DqValidationResult validateRecord(ValidateRecordRequest req) {
    auto rules = ruleRepo.findActive(req.tenantId);
    auto result = engine.validate(req.tenantId, req.recordId, req.datasetId,
        req.fieldValues, rules);
    resultRepo.save(result);
    return result;
  }

  /// Validate a batch of records.
  DqValidationResult[] validateBatch(ValidateBatchRequest req) {
    auto rules = ruleRepo.findActive(req.tenantId);
    DqValidationResult[] results;

    foreach (rec; req.records) {
      auto result = engine.validate(req.tenantId, rec.recordId, req.datasetId,
          rec.fieldValues, rules);
      resultRepo.save(result);
      results ~= result;
    }

    return results;
  }

  /// Retrieve validation results for a dataset.
  DqValidationResult[] getResultsByDataset(TenantId tenantId, DatasetId datasetId) {
    return resultRepo.findByDataset(tenantId, datasetId);
  }

  /// Retrieve validation result for a single record.
  DqValidationResult getResultByRecord(TenantId tenantId, RecordId recordId) {
    return resultRepo.findByRecord(tenantId, recordId);
  }
}
