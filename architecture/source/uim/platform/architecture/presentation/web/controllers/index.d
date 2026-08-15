module uim.platform.architecture.presentation.web.controllers.index;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
void handleIndex(HTTPServerRequest req, HTTPServerResponse res) {
    if (!req.session)
    {
        res.redirect("/web/login");
        return;
    }

    // Werte mit Typisierung auslesen (inkl. Fallback-Wert)
    string username = req.session.get!string("username", "Gast");
    bool isLoggedIn = req.session.get!bool("isLoggedIn", false);
    string lang = req.session.get!string("lang", "de");

    auto translations = getTranslations(lang);
    res.render!("index.dt", username, lang, translations);
}