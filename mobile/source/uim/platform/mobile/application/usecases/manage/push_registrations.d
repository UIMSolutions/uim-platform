/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.push_registrations;
// import uim.platform.mobile.domain.ports.repositories.push_registrations;
// import uim.platform.mobile.domain.entities.push_registration;
// import uim.platform.mobile.domain.types;
// import uim.platform.mobile.application.dto;
// import std.uuid : randomUUID;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class ManagePushRegistrationsUseCase { // TODO: UIMUseCase {
    private PushRegistrationRepository repo;

    this(PushRegistrationRepository repo) {
        this.repo = repo;
    }

    CommandResult registerPushRegistration(CreatePushRegistrationRequest r) {
        auto existing = repo.findByDeviceAndApp(r.deviceId, r.appId);
        if (!existing.isNull) {
            existing.pushToken = r.pushToken;
            existing.topics = r.topics;
            existing.updatedAt = Clock.currStdTime();
            repo.update(existing);
            return CommandResult(true, existing.id.value, "");
        }
        PushRegistration reg;
        reg.initEntity(r.tenantId, r.createdBy);

        reg.appId = r.appId;
        reg.deviceId = r.deviceId;
        reg.provider = parseProvider(r.provider);
        reg.pushToken = r.pushToken;
        reg.topics = r.topics;
        reg.status = PushRegStatus.active;
        reg.registeredAt = Clock.currStdTime();
        reg.updatedAt = reg.registeredAt;

        repo.save(reg);
        return CommandResult(true, reg.id.value, "");
    }

    PushRegistration getPushRegistration(PushRegistrationId id) {
        return repo.findById(tenantId, id);
    }

    PushRegistration[] listPushRegistrationsByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    PushRegistration[] listPushRegistrationsByTopic(MobileAppId appId, string topic) {
        return repo.findByTopic(appId, topic);
    }

    CommandResult deletePushRegistration(PushRegistrationId id) {
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }

    size_t countPushRegistrationsByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }
}
