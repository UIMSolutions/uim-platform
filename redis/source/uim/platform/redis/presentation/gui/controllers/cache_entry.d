/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.controllers.cache_entry;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class GuiCacheEntryController {
    private GuiCacheEntryModel  _model;
    private GuiCacheEntryView   _view;
    private ManageCacheEntriesUseCase _useCase;
    private TenantIf _tenantId;

    this(ManageCacheEntriesUseCase useCase, TenantIf tenantId = TenantId("default")) {
        _useCase = useCase; _tenantId = tenantId;
        _model = new GuiCacheEntryModel(); _view = new GuiCacheEntryView();
    }

    void setTenant(TenantIf tenantId) { _tenantId = tenantId; }
    GuiCacheEntryModel model() { return _model; }

    Json loadList() {
        _model.setEntries(_useCase.listCacheEntries(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json loadDetail(CacheEntryId id) {
        auto e = _useCase.getCacheEntry(_tenantId, id);
        _model.setSelected(e, !e.isNull);
        return _view.buildDetailDescriptor(_model);
    }
    Json handleCreate(CacheEntryDTO dto) {
        dto.tenantId = _tenantId;
        auto result = _useCase.createCacheEntry(dto);
        if (result.success) _model.setSuccess("Set key: " ~ dto.key);
        else                _model.setError(result.error);
        _model.setEntries(_useCase.listCacheEntries(_tenantId));
        return _view.buildListDescriptor(_model);
    }
    Json handleDelete(CacheEntryId id) {
        auto result = _useCase.deleteCacheEntry(_tenantId, id);
        if (result.success) _model.setSuccess("Deleted");
        else                _model.setError(result.error);
        _model.setEntries(_useCase.listCacheEntries(_tenantId));
        return _view.buildListDescriptor(_model);
    }
}
