/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.user_sessions;

// import uim.platform.mobile.domain.ports.repositories.user_sessions;
// import uim.platform.mobile.domain.entities.user_session;
// import uim.platform.mobile.domain.types;
// import uim.platform.mobile.application.dto;
// import std.uuid : randomUUID;
import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class ManageUserSessionsUseCase { // TODO: UIMUseCase {
    private UserSessionRepository repo;

    this(UserSessionRepository repo) {
        this.repo = repo;
    }

    CommandResult createUserSession(CreateUserSessionRequest r) {
        UserSession session;
        session.id = randomUUID();
        session.tenantId = r.tenantId;
        session.appId = r.appId;
        session.userId = r.userId;
        session.deviceId = r.deviceId;
        session.ipAddress = r.ipAddress;
        session.userAgent = r.userAgent;
        session.status = SessionStatus.active;
        session.startedAt = currentTimestamp();
        session.lastActivityAt = session.startedAt;
        session.createdAt = session.startedAt;
        session.updatedAt = session.startedAt;
        repo.save(session);
        return CommandResult(true, session.id.value, "");
    }

    CommandResult terminateUserSession(UserSessionId id) {
        auto session = repo.findById(tenantId, id);
        if (session.isNull)
            return CommandResult(false, "", "Session not found");
        session.status = SessionStatus.terminated;
        session.endedAt = currentTimestamp();
        session.updatedAt = currentTimestamp();
        
        repo.update(session);
        return CommandResult(true, session.id.value, "");
    }

    UserSession getUserSession(UserSessionId id) {
        return repo.findById(tenantId, id);
    }

    UserSession[] listUserSessionsByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    UserSession[] listActiveUserSessions(MobileAppId appId) {
        return repo.findActive(appId);
    }

    CommandResult deleteUserSession(UserSessionId id) {
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }

    size_t countActive(MobileAppId appId) {
        return repo.countActive(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
