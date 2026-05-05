/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.push_registrations;

import uim.platform.mobile.domain.ports.repositories.push_registrations;
import uim.platform.mobile.domain.entities.push_registration;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManagePushRegistrationsUseCase { // TODO: UIMUseCase {
    private PushRegistrationRepository repo;

    this(PushRegistrationRepository repo) {
        this.repo = repo;
    }

    CommandResult register(CreatePushRegistrationRequest r) {
        auto existing = repo.findByDeviceAndApp(r.deviceId, r.appId);
        if (!existing.isNull) {
            existing.pushToken = r.pushToken;
            existing.topics = r.topics;
            existing.updatedAt = currentTimestamp();
            repo.update(existing);
            return CommandResult(true, existing.id.value, "");
        }
        PushRegistration reg;
        reg.id = randomUUID();
        reg.tenantId = r.tenantId;
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

    PushRegistration get_(PushRegistrationId id) {
        return repo.findById(id);
    }

    PushRegistration[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    PushRegistration[] listByTopic(MobileAppId appId, string topic) {
        return repo.findByTopic(appId, topic);
    }

    void remove(PushRegistrationId id) {
        repo.removeById(id);
    }

    size_t countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static PushProvider parseProvider(string s) {
        switch (s) {
            case "apns": return PushProvider.apns;
            case "fcm": return PushProvider.fcm;
            case "wns": return PushProvider.wns;
            case "webpush": return PushProvider.webpush;
            default: return PushProvider.fcm;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
