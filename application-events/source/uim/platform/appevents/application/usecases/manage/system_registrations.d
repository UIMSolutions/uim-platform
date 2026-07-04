/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.system_registrations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.system_registration;
import uim.platform.appevents.domain.repositories.system_registrations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.application.dto;
import std.datetime.systime : Clock;

@safe:

class ManageSystemRegistrationsUseCase {
    private SystemRegistrationRepository repo;

    this(SystemRegistrationRepository repo) { this.repo = repo; }

    SystemRegistration getSystemRegistration(TenantId tenantId, SystemRegistrationId id) {
        return repo.findById(tenantId, id);
    }

    SystemRegistration[] listSystemRegistrations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SystemRegistration[] listByFormation(TenantId tenantId, FormationId formationId) {
        return repo.findByFormation(tenantId, formationId);
    }

    CommandResult registerSystem(SystemRegistrationDTO dto) {
        auto reg = SystemRegistration(dto.tenantId, dto.registrationId, dto.registrationId);
        reg.formationId = dto.formationId;
        reg.systemId = dto.systemId;
        reg.systemType = dto.systemType;
        reg.systemUrl = dto.systemUrl;
        reg.status = dto.status;
        reg.registeredAt = Clock.currStdTime();
        repo.save(reg);
        return CommandResult(true, reg.id.value, "");
    }

    CommandResult deleteSystemRegistration(TenantId tenantId, SystemRegistrationId id) {
        auto reg = repo.findById(tenantId, id);
        if (reg.isNull) return CommandResult(false, "", "System registration not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
