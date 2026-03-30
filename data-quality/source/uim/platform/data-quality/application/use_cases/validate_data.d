module application.use_cases.validate_data;

import domain.types;
import domain.entities.validation_rule;
import domain.entities.validation_result;
import domain.ports.validation_rule_repository;
import domain.ports.validation_result_repository;
import domain.services.validation_engine;
import application.dto;

class ValidateDataUseCase
{
    private ValidationRuleRepository ruleRepo;
    private ValidationResultRepository resultRepo;
    private ValidationEngine engine;

    this(ValidationRuleRepository ruleRepo,
        ValidationResultRepository resultRepo,
        ValidationEngine engine)
    {
        this.ruleRepo = ruleRepo;
        this.resultRepo = resultRepo;
        this.engine = engine;
    }

    /// Validate a single record against active rules.
    ValidationResult validateRecord(ValidateRecordRequest req)
    {
        auto rules = ruleRepo.findActive(req.tenantId);
        auto result = engine.validate(
            req.recordId, req.tenantId, req.datasetId,
            req.fieldValues, rules);
        resultRepo.save(result);
        return result;
    }

    /// Validate a batch of records.
    ValidationResult[] validateBatch(ValidateBatchRequest req)
    {
        auto rules = ruleRepo.findActive(req.tenantId);
        ValidationResult[] results;

        foreach (ref rec; req.records)
        {
            auto result = engine.validate(
                rec.recordId, req.tenantId, req.datasetId,
                rec.fieldValues, rules);
            resultRepo.save(result);
            results ~= result;
        }

        return results;
    }

    /// Retrieve validation results for a dataset.
    ValidationResult[] getResultsByDataset(TenantId tenantId, DatasetId datasetId)
    {
        return resultRepo.findByDataset(tenantId, datasetId);
    }

    /// Retrieve validation result for a single record.
    ValidationResult* getResultByRecord(RecordId recordId, TenantId tenantId)
    {
        return resultRepo.findByRecord(recordId, tenantId);
    }
}
