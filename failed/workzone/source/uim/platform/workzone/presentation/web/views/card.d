/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.views.card;

import uim.platform.workzone.presentation.web.models.card;
import uim.platform.workzone.presentation.web.views.layout;
import std.array : appender;

@safe:
/// Render the card catalogue page.
string renderCardList(CardListViewModel vm) {
    auto buf = appender!string;

    if (vm.hasError) {
        buf ~= `<div class="alert alert-danger">` ~ escapeHtml(vm.errorMessage) ~ `</div>`;
    }

    buf ~= `
<div class="d-flex justify-content-between align-items-center mb-3">
  <h4 class="mb-0">Card Catalogue</h4>
  <a href="/ui/cards/new" class="btn btn-primary btn-sm">+ New Card</a>
</div>
<div class="row g-3">`;

    if (vm.items.length == 0) {
        buf ~= `<div class="col-12 text-center text-muted py-4">No cards defined yet.</div>`;
    }
    foreach (c; vm.items) {
        buf ~= `
<div class="col-md-4">
  <div class="card shadow-sm h-100">
    <div class="card-body">
      <div class="d-flex justify-content-between">
        <h6 class="card-title mb-1">` ~ escapeHtml(c.title) ~ `</h6>
        <span class="badge ` ~ c.activeCssClass ~ `">` ~ escapeHtml(c.activeLabel) ~ `</span>
      </div>
      <p class="text-muted small mb-2">` ~ escapeHtml(c.subtitle) ~ `</p>
      <span class="badge bg-light text-dark border">` ~ escapeHtml(c.cardTypeLabel) ~ `</span>
    </div>
    <div class="card-footer bg-transparent">
      <a href="/ui/cards/` ~ escapeHtml(c.id) ~ `/edit" class="btn btn-outline-secondary btn-sm">Edit</a>
    </div>
  </div>
</div>`;
    }

    buf ~= `</div>`;

    return renderLayout("Card Catalogue", buf[], "cards");
}
