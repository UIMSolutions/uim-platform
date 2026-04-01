module uim.platform.auditlog.application.usecases.manage.audit_config;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_config;
import uim.platform.auditlog.domain.ports.audit_config_repository;
import uim.platform.auditlog.application.dto;

@safe:
class ManageAuditConfigUseCase {
    private AuditConfigRepository repo;

    this(AuditConfigRepository repo) {
        this.repo = repo;
    }

    CommandResult createConfig(CreateAuditConfigRequest req) {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");

        // Only one config per tenant
        if (repo.existsByTenant(req.tenantId))
            return CommandResult("", "Audit configuration already exists for this tenant");

        auto now = Clock.currStdTime();
        auto cfg = AuditConfig();
        cfg.id = randomUUID().toString();
        cfg.tenantId = req.tenantId;
        cfg.name = req.name.length > 0 ? req.name : "Default";
        cfg.status = ConfigStatus.enabled;
        cfg.logDataAccess = req.logDataAccess;
        cfg.logDataModification = req.logDataModification;
        cfg.logSecurityEvents = req.logSecurityEvents;
        cfg.logConfigurationChanges = req.logConfigurationChanges;
        cfg.enableDataMasking = req.enableDataMasking;
        cfg.maskedFields = req.maskedFields;
        cfg.excludedServices = req.excludedServices;
        cfg.minimumSeverity = req.minimumSeverity;
        cfg.rateLimitPerSecond = req.rateLimitPerSecond > 0 ? req.rateLimitPerSecond : 8;
        cfg.createdAt = now;
        cfg.updatedAt = now;

        repo.save(cfg);
        return CommandResult(cfg.id, "");
    }

    AuditConfig* getConfig(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AuditConfig[] listConfigs() {
        return repo.findAll();
    }

    CommandResult updateConfig(UpdateAuditConfigRequest req) {
        auto cfg = repo.findById(req.id);
        if (cfg is null)
            return CommandResult("", "Audit config not found");

        if (req.name.length > 0)
            cfg.name = req.name;
        cfg.status = req.status;
        cfg.logDataAccess = req.logDataAccess;
        cfg.logDataModification = req.logDataModification;
        cfg.logSecurityEvents = req.logSecurityEvents;
        cfg.logConfigurationChanges = req.logConfigurationChanges;
        cfg.enableDataMasking = req.enableDataMasking;
        cfg.maskedFields = req.maskedFields;
        cfg.excludedServices = req.excludedServices;
        cfg.minimumSeverity = req.minimumSeverity;
        if (req.rateLimitPerSecond > 0)
            cfg.rateLimitPerSecond = req.rateLimitPerSecond;
        cfg.updatedAt = Clock.currStdTime();

        repo.update(*cfg);
        return CommandResult(cfg.id, "");
    }

    void deleteConfig(AuditConfigId id, TenantId tenantId) {
        repo.remove(id, tenantId);
    }
}
