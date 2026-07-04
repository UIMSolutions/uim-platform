/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.event_filter;

// import uim.platform.service;
// import uim.platform.appevents.application.dto;
// import uim.platform.appevents.application.usecases.manage.event_filters;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.presentation.gui.models.event_filter;
// import uim.platform.appevents.presentation.gui.views.event_filter;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:


class GuiEventFilterController {
    private GuiEventFilterModel        _model;
    private GuiEventFilterView         _view;
    private ManageEventFiltersUseCase  _useCase;

    this(ManageEventFiltersUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiEventFilterModel();
        _view    = new GuiEventFilterView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listEventFilters(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, EventFilterId id) {
        auto item = _useCase.getEventFilter(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, EventFilterDTO dto) {
        auto result = _useCase.createEventFilter(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Created: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json update(TenantId tenantId, EventFilterDTO dto) {
        auto result = _useCase.updateEventFilter(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Updated: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, EventFilterId id) {
        auto result = _useCase.deleteEventFilter(tenantId, id);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
