/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.dead_letter_entry;

// import uim.platform.service;
// import uim.platform.appevents.application.dto;
// import uim.platform.appevents.application.usecases.manage.dead_letter_entries;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.presentation.gui.models.dead_letter_entry;
// import uim.platform.appevents.presentation.gui.views.dead_letter_entry;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:


class GuiDeadLetterEntryController {
    private GuiDeadLetterEntryModel        _model;
    private GuiDeadLetterEntryView         _view;
    private ManageDeadLetterEntriesUseCase _useCase;

    this(ManageDeadLetterEntriesUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiDeadLetterEntryModel();
        _view    = new GuiDeadLetterEntryView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listDeadLetterEntries(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, DeadLetterEntryId id) {
        auto item = _useCase.getDeadLetterEntry(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, DeadLetterEntryDTO dto) {
        auto result = _useCase.createDeadLetterEntry(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Created: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, DeadLetterEntryId id) {
        auto result = _useCase.deleteDeadLetterEntry(tenantId, id);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
