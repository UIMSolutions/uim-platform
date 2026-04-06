/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.tls_configurations;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageTlsConfigurationsUseCase : UIMUseCase {
    private TlsConfigurationRepository repo;

    this(TlsConfigurationRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateTlsConfigurationRequest r) {
        auto err = DomainValidator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "TLS configuration already exists");

        TlsConfiguration c;
        c.id = r.id;
        c.tenantId = r.tenantId;
        c.name = r.name;
        c.description = r.description;
        c.http2Enabled = r.http2Enabled;
        c.hstsEnabled = r.hstsEnabled;
        c.hstsMaxAge = r.hstsMaxAge;
        c.hstsIncludeSubDomains = r.hstsIncludeSubDomains;
        c.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        c.createdAt = now;
        c.modifiedAt = now;

        repo.save(c);
        return CommandResult(true, c.id, "");
    }

    TlsConfiguration get_(TlsConfigurationId id) {
        return repo.findById(id);
    }

    TlsConfiguration[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateTlsConfigurationRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.length == 0)
            return CommandResult(false, "", "TLS configuration not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.http2Enabled = r.http2Enabled;
        existing.hstsEnabled = r.hstsEnabled;
        existing.hstsMaxAge = r.hstsMaxAge;
        existing.hstsIncludeSubDomains = r.hstsIncludeSubDomains;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(TlsConfigurationId id) {
        auto existing = repo.findById(id);
        if (existing.id.length == 0)
            return CommandResult(false, "", "TLS configuration not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
