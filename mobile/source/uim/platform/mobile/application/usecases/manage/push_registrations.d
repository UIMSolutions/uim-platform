/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.push_registrations;
// import uim.platform.mobile.domain.ports.repositories.push_registrations;
// import uim.platform.mobile.domain.entities.push_registration;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManagePushRegistrationsUseCase { // TODO: UIMUseCase {
    private PushRegistrationRepository repo;

    this(PushRegistrationRepository repo) {
        this.repo = repo;
    }

    CommandResult registerPushRegistration(CreatePushRegistrationRequest r) {
        auto existing = repo.findByDeviceAndApp(r.tenantId, r.deviceId, r.appId);
        if (!existing.isNull) {
            existing.pushToken = r.pushToken;
            existing.topics = r.topics;
            existing.updatedAt = currentTimestamp();
            repo.update(existing);
            return CommandResult(true, existing.id.value, "");
        }
        
        auto reg = PushRegistration(r.tenantId);
        reg.appId = r.appId;
        reg.deviceId = r.deviceId;
        reg.provider = parseProvider(r.provider);
        reg.pushToken = r.pushToken;
        reg.topics = r.topics;
        reg.status = PushRegStatus.active;
        reg.registeredAt = currentTimestamp();
        reg.updatedAt = reg.registeredAt;

        repo.save(reg);
        return CommandResult(true, reg.id.value, "");
    }

    PushRegistration getPushRegistration(TenantId tenantId, PushRegistrationId id) {
        return repo.findById(tenantId, id);
    }

    PushRegistration[] listPushRegistrationsByApp(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    PushRegistration[] listPushRegistrationsByTopic(TenantId tenantId, MobileAppId appId, string topic) {
        return repo.findByTopic(tenantId, appId, topic);
    }

    CommandResult deletePushRegistration(TenantId tenantId, PushRegistrationId id) {
        auto reg = repo.findById(tenantId, id);
        if (reg.isNull)
            return CommandResult(false, "", "Push registration not found");

        repo.remove(reg);
        return CommandResult(true, reg.id.value, "");
    }

    size_t countPushRegistrationsByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }
}
