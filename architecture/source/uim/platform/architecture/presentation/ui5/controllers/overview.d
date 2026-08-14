module uim.platform.architecture.presentation.ui5.controllers.overview;

import std.conv : to;
import std.string : lastIndexOf;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class OverviewUi5Controller {
    protected OverviewUi5Model model;
    protected OverviewUi5View view;

    this() {
        this.model = new OverviewUi5Model();
        this.view = new OverviewUi5View();
    }
    
    this(OverviewUi5Model model, OverviewUi5View view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/ui5/architecture", &handleOverview);
    }

    private void handleOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderOverview(tenant(req)));
    }


}
