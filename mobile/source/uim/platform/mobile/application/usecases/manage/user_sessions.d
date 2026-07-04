/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.user_sessions;
// import uim.platform.mobile.domain.ports.repositories.user_sessions;
// import uim.platform.mobile.domain.entities.user_session;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class ManageUserSessionsUseCase { // TODO: UIMUseCase {
    private UserSessionRepository repo;

    this(UserSessionRepository repo) {
        this.repo = repo;
    }

    CommandResult createUserSession(CreateUserSessionRequest r) {
        auto ses = UserSession(r.tenantId); //, UserId("test-user"));
        ses.appId = r.appId;
        ses.userId = r.userId;
        ses.deviceId = r.deviceId;
        ses.ipAddress = r.ipAddress;
        ses.userAgent = r.userAgent;
        ses.status = SessionStatus.active;
        ses.startedAt = ses.updatedAt;
        ses.lastActivityAt = ses.startedAt;

        repo.save(ses);
        return CommandResult(true, ses.id.value, "");
    }

    CommandResult terminateUserSession(TenantId tenantId, UserSessionId id) {
        auto ses = repo.findById(tenantId, id);
        if (ses.isNull)
            return CommandResult(false, "", "Session not found");
        ses.status = SessionStatus.terminated;
        ses.endedAt = currentTimestamp();
        ses.updatedAt = currentTimestamp();

        repo.update(ses);
        return CommandResult(true, ses.id.value, "");
    }

    UserSession getUserSession(TenantId tenantId, UserSessionId id) {
        return repo.findById(tenantId, id);
    }

    UserSession[] listUserSessionsByApp(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    UserSession[] listActiveUserSessions(TenantId tenantId, MobileAppId appId) {
        return repo.findActive(tenantId, appId);
    }

    CommandResult deleteUserSession(TenantId tenantId, UserSessionId id) {
        auto ses = repo.findById(tenantId, id);
        if (ses.isNull)
            return CommandResult(false, "", "Session not found");

        repo.remove(ses);
        return CommandResult(true, ses.id.value, "");
    }

    size_t countActive(TenantId tenantId, MobileAppId appId) {
        return repo.countActive(tenantId, appId);
    }

}
