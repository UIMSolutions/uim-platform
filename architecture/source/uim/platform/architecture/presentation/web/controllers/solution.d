module uim.platform.architecture.presentation.web.controllers.solution;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
void handleSolution(HTTPServerRequest req, HTTPServerResponse res) {
    if (!req.session || !req.session.get!bool("isLoggedIn", false)) {
        res.redirect("/web/login");
        return;
    }

    string username = req.session.get!string("username", "User");
    string lang = req.session.get!string("lang", "de");
    auto translations = getTranslations(lang);

    res.render!("solution.dt", username, lang, translations);
}