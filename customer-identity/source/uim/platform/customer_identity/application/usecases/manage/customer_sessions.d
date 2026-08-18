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
    private ICustomerSessionRepository repo;

    this(ICustomerSessionRepository repo) {
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

    UsecaseResult createSession(CustomerSessionDTO dto) {
        auto s = CustomerSession(dto.tenantId); //, dto.createdBy);
        s.customerId = dto.customerId;
        s.token = dto.token;
        s.deviceInfo = dto.deviceInfo;
        s.ipAddress = dto.ipAddress;
        s.userAgent = dto.userAgent;
        s.expiresAt = dto.expiresAt;
        s.status = SessionStatus.active;

        if (!IdentityValidator.isValidSession(s))
            return UsecaseResult(false, "", "Invalid session data");

        repo.save(s);
        return UsecaseResult(true, s.id.value, "");
    }

    UsecaseResult revokeSession(TenantId tenantId, CustomerSessionId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Session not found");

        existing.status = SessionStatus.revoked;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult revokeAllSessions(TenantId tenantId, CustomerId customerId) {
        repo.revokeByCustomer(tenantId, customerId);
        return UsecaseResult(true, customerId.value, "");
    }

    UsecaseResult deleteSession(TenantId tenantId, CustomerSessionId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Session not found");

        repo.remove(existing);
        return UsecaseResult(true, existing.id.value, "");
    }
}
