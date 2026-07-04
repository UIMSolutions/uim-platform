/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.customer_sessions;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ManageCustomerSessionsUseCase {
    private CustomerSessionRepository repo;

    this(CustomerSessionRepository repo) {
        this.repo = repo;
    }

    CustomerSession getSession(TenantId tenantId, CustomerSessionId id) {
        return repo.findById(tenantId, id);
    }

    CustomerSession[] listSessions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CustomerSession[] listByCustomer(TenantId tenantId, CustomerId customerId) {
        return repo.findByCustomer(tenantId, customerId);
    }

    CommandResult createSession(CustomerSessionDTO dto) {
        CustomerSession s;
        s.initEntity(dto.tenantId, dto.createdBy);
        s.customerId = dto.customerId;
        s.token = dto.token;
        s.deviceInfo = dto.deviceInfo;
        s.ipAddress = dto.ipAddress;
        s.userAgent = dto.userAgent;
        s.expiresAt = dto.expiresAt;
        s.status = SessionStatus.active;

        if (!IdentityValidator.isValidSession(s))
            return CommandResult(false, "", "Invalid session data");

        repo.save(s);
        return CommandResult(true, s.id.value, "");
    }

    CommandResult revokeSession(TenantId tenantId, CustomerSessionId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Session not found");

        existing.status = SessionStatus.revoked;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult revokeAllSessions(TenantId tenantId, CustomerId customerId) {
        repo.revokeByCustomer(tenantId, customerId);
        return CommandResult(true, customerId.value, "");
    }

    CommandResult deleteSession(TenantId tenantId, CustomerSessionId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Session not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
