/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.dead_letter_entry;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.dead_letter_entry;
import uim.platform.appevents.presentation.web.views.dead_letter_entry;

@safe:

class WebDeadLetterEntryController {
    private WebDeadLetterEntryModel        _model;
    private WebDeadLetterEntryView         _view;
    private ManageDeadLetterEntriesUseCase _useCase;

    this(ManageDeadLetterEntriesUseCase useCase) {
        _useCase = useCase;
        _model   = new WebDeadLetterEntryModel();
        _view    = new WebDeadLetterEntryView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listDeadLetterEntries(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, DeadLetterEntryId id) {
        auto item = _useCase.getDeadLetterEntry(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, DeadLetterEntryDTO dto) {
        auto result = _useCase.createDeadLetterEntry(dto);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Dead letter entry created: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, DeadLetterEntryId id) {
        auto result = _useCase.deleteDeadLetterEntry(tenantId, id);
        if (result.hasError) return _view.renderError(result.errorMessage);
        return _view.renderSuccess("Dead letter entry deleted: " ~ result.id);
    }
}
