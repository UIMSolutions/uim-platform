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
import uim.platform.appevents.domain.enums.system_type;
import uim.platform.appevents.domain.enums.system_status;
import uim.platform.appevents.application.dto;
import std.datetime.systime : Clock;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageSystemRegistrationsUseCase {
    private SystemRegistrationRepository _repo;

    this(SystemRegistrationRepository repo) {
        _repo = repo;
    }

    SystemRegistration getSystemRegistration(TenantId tenantId, SystemRegistrationId id) {
        return _repo.findById(tenantId, id);
    }

    SystemRegistration[] listSystemRegistrations(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    SystemRegistration[] listByFormation(TenantId tenantId, FormationId formationId) {
        return _repo.findByFormation(tenantId, formationId);
    }

    CommandResult registerSystem(TenantId tenantId, SystemRegistrationDTO dto) {
        SystemRegistration reg;
        reg.id = SystemRegistrationId(randomUUID().to!string);
        reg.tenantId = tenantId;
        reg.formationId = FormationId(dto.formationId);
        reg.systemId = dto.systemId;
        reg.systemType = dto.systemType;
        reg.systemUrl = dto.systemUrl;
        reg.status = dto.status;
        reg.registeredAt = Clock.currTime().toUnixTime();
        _repo.save(tenantId, reg);
        return CommandResult(true, reg.id.value);
    }

    CommandResult updateSystemRegistration(TenantId tenantId, SystemRegistrationId id, SystemRegistrationDTO dto) {
        auto reg = _repo.findById(tenantId, id);
        if (reg.id.isNull) return CommandResult(false, "System registration not found");
        reg.formationId = FormationId(dto.formationId);
        reg.systemId = dto.systemId;
        reg.systemType = dto.systemType;
        reg.systemUrl = dto.systemUrl;
        reg.status = dto.status;
        _repo.save(tenantId, reg);
        return CommandResult(true, id.value);
    }

    CommandResult deleteSystemRegistration(TenantId tenantId, SystemRegistrationId id) {
        auto reg = _repo.findById(tenantId, id);
        if (reg.id.isNull) return CommandResult(false, "System registration not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
