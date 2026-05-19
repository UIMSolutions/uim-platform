/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.controllers.backup_policy;

import uim.platform.postgres;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebBackupPolicyController {
    private WebBackupPolicyModel   _model;
    private WebBackupPolicyView    _view;
    private ManageBackupPoliciesUseCase _useCase;

    this(ManageBackupPoliciesUseCase useCase) {
        _useCase = useCase;
        _model   = new WebBackupPolicyModel();
        _view    = new WebBackupPolicyView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/postgres/backup-policies",   &handleList);
        router.get("/web/postgres/backup-policies/*", &handleDetail);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto list = _useCase.listBackupPolicies(tenantId);
        _model.setPolicies(list);
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = BackupPolicyId(extractIdFromPath(req.requestURI.to!string));
        auto p  = _useCase.getBackupPolicy(tenantId, id);
        _model.setSelected(p, !p.isNull);
        _view.renderDetail(res, _model);
    }
}
