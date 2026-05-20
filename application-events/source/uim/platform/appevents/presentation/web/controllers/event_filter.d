/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.event_filter;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.event_filter;
import uim.platform.appevents.presentation.web.views.event_filter;

@safe:

class WebEventFilterController {
    private WebEventFilterModel        _model;
    private WebEventFilterView         _view;
    private ManageEventFiltersUseCase  _useCase;

    this(ManageEventFiltersUseCase useCase) {
        _useCase = useCase;
        _model   = new WebEventFilterModel();
        _view    = new WebEventFilterView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listEventFilters(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, EventFilterId id) {
        auto item = _useCase.getEventFilter(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, EventFilterDTO dto) {
        auto result = _useCase.createEventFilter(dto);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Filter created: " ~ result.id)
            .set("id", result.id);
    }

    Json update(TenantId tenantId, EventFilterDTO dto) {
        auto result = _useCase.updateEventFilter(dto);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Filter updated: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, EventFilterId id) {
        auto result = _useCase.deleteEventFilter(tenantId, id);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Filter deleted: " ~ result.id);
    }
}
