module uim.platform.architecture.presentation.web.controllers.login;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
void getLogin(HTTPServerRequest req, HTTPServerResponse res) {
    string username = "";
    string errorMessage = "";
    string lang = req.query.get("lang", "en");
    auto translations = getTranslations(lang);

    res.render!("login.dt", username, errorMessage, lang, translations);
}

void handleLogin(HTTPServerRequest req, HTTPServerResponse res) {
    string username = req.form.get("username", "").strip;
    string password = req.form.get("password", "").strip;
    string errorMessage = "";

    // Basic Credential Validation (replace with DB lookup / password hash check)
    if (username == "admin" && password == "secret123") {
        // 1. Create a secure session
        Session session = res.startSession();
        session.set("username", username);
        session.set("isLoggedIn", true);
        session.set("tenant", "default");

        logInfo("User '%s' successfully logged in.", username);
        res.redirect("/web");
        return;
    }

    // 2. Authentication failed
    logWarn("Failed login attempt for user '%s'.", username);
    errorMessage = "Invalid username or password.";
    string lang = req.query.get("lang", "en");
    auto translations = getTranslations(lang);

    // Render form again, retaining entered username
    res.render!("login.dt", username, errorMessage, lang, translations);
}