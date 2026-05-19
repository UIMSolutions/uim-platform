/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.controllers.backup_policy;

import uim.platform.redis;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebBackupPolicyController {
    private WebBackupPolicyModel  _model;
    private WebBackupPolicyView   _view;
    private ManageBackupPoliciesUseCase _useCase;

    this(ManageBackupPoliciesUseCase useCase) {
        _useCase = useCase;
        _model   = new WebBackupPolicyModel();
        _view    = new WebBackupPolicyView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/redis/backup-policies",    &handleList);
        router.get("/web/redis/backup-policies/*",  &handleDetail);
        router.post("/web/redis/backup-policies",   &handleCreate);
        router.post("/web/redis/backup-policies/*", &handleDelete);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        _model.setPolicies(_useCase.listBackupPolicies(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = BackupPolicyId(extractIdFromPath(req.requestURI.to!string));
        auto p = _useCase.getBackupPolicy(tenantId, id);
        _model.setSelected(p, !p.isNull);
        _view.renderDetail(res, _model);
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto data = req.json;
        BackupPolicyDTO dto;
        dto.tenantId      = tenantId;
        dto.instanceId    = ServiceInstanceId(data.getString("instanceId", ""));
        dto.enabled       = data.getBool("enabled", true);
        dto.intervalHours = data.getLong("intervalHours", 24);
        dto.retentionDays = data.getLong("retentionDays", 7);
        dto.backupLocation = data.getString("backupLocation", "");
        auto result = _useCase.createBackupPolicy(dto);
        if (result.success) _model.setSuccess("Policy created: " ~ result.id);
        else                _model.setError(400, result.error);
        _model.setPolicies(_useCase.listBackupPolicies(tenantId));
        _view.renderList(res, _model);
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-ID", "default"));
        auto id = BackupPolicyId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteBackupPolicy(tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(400, result.error);
        _model.setPolicies(_useCase.listBackupPolicies(tenantId));
        _view.renderList(res, _model);
    }
}
