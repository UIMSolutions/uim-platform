/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.tls_configurations;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageTlsConfigurationsUseCase { // TODO: UIMUseCase {
    private TlsConfigurationRepository repo;

    this(TlsConfigurationRepository repo) {
        this.repo = repo;
    }

    CommandResult createTlsConfiguration(CreateTlsConfigurationRequest r) {
        auto err = DomainValidator.validate(r.tlsConfigurationId.value, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.tlsConfigurationId);
        if (!existing.isNull)
            return CommandResult(false, "", "TLS configuration already exists");

        TlsConfiguration c;
        c.initEntity(r.tenantId, r.createdBy);

        c.id = r.tlsConfigurationId;
        c.name = r.name;
        c.description = r.description;
        c.http2Enabled = r.http2Enabled;
        c.hstsEnabled = r.hstsEnabled;
        c.hstsMaxAge = r.hstsMaxAge;
        c.hstsIncludeSubDomains = r.hstsIncludeSubDomains;

        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    TlsConfiguration getTlsConfiguration(TenantId tenantId, TlsConfigurationId id) {
        return repo.findById(tenantId, id);
    }

    TlsConfiguration[] listTlsConfigurations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateTlsConfiguration(UpdateTlsConfigurationRequest r) {
        auto existing = repo.findById(r.tenantId, r.tlsConfigurationId);
        if (existing.isNull)
            return CommandResult(false, "", "TLS configuration not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.http2Enabled = r.http2Enabled;
        existing.hstsEnabled = r.hstsEnabled;
        existing.hstsMaxAge = r.hstsMaxAge;
        existing.hstsIncludeSubDomains = r.hstsIncludeSubDomains;
        existing.updatedBy = r.updatedBy;

        
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteTlsConfiguration(TenantId tenantId, TlsConfigurationId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "TLS configuration not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
