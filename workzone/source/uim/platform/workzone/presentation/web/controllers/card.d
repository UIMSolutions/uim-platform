/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.controllers.card;

import uim.platform.workzone;
import uim.platform.workzone.presentation.web.models.card;
import uim.platform.workzone.presentation.web.views.card;
import uim.platform.workzone.presentation.web.views.error;

mixin(ShowModule!());

@safe:
/// Web MVC controller — renders HTML for the card catalogue.
class CardWebController : PlatformController {
    private ManageCardsUseCase useCase;

    this(ManageCardsUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/ui/cards",     &handleList);
        router.get("/ui/cards/*",   &handleDetail);
    }

    private void handleList(scope HTTPServerRequest req,
                            scope HTTPServerResponse res) {
        immutable tenantId = req.getTenantId;
        try {
            auto cards = useCase.listCards(tenantId);
            CardListViewModel vm;
            vm.tenantId = tenantId;
            foreach (c; cards)
                vm.items ~= CardViewModel.from(c);
            res.writeBody(renderCardList(vm), "text/html; charset=utf-8");
        } catch (Exception e) {
            CardListViewModel vm;
            vm.errorMessage = e.msg;
            res.statusCode = 500;
            res.writeBody(renderCardList(vm), "text/html; charset=utf-8");
        }
    }

    private void handleDetail(scope HTTPServerRequest req,
                              scope HTTPServerResponse res) {
        immutable id = extractIdFromPath(req);
        if (id == "new") { handleNew(req, res); return; }

        res.writeBody(renderError(501, "Card detail not yet implemented"),
                      "text/html; charset=utf-8");
    }

    private void handleNew(scope HTTPServerRequest req,
                           scope HTTPServerResponse res) {
        res.writeBody(renderError(501, "Card creation UI not yet implemented"),
                      "text/html; charset=utf-8");
    }
}
