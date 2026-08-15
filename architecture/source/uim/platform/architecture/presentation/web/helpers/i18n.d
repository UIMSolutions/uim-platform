module uim.platform.architecture.presentation.web.helpers.i18n;

import std.string : replace;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

string[string][string] dictionary = [
    "en": [
        "loginPage": "Login Page",
        "username": "Username",
        "password": "Password",
        "welcome": "Welcome back, %s!",
        "login": "Log In",
        "logout": "Log Out",
        "home": "Home",
        "architecture": "Architecture",
        "business": "Business",
        "data": "Data",
        "solutions": "Solutions",
        "technology": "Technology",
        "contact": "Contact",
        "settings": "Settings"
    ],
    "de": [
        "loginPage": "Anmeldeseite",
        "username": "Benutzername",
        "password": "Passwort",
        "welcome": "Willkommen zurück, %s!",
        "login": "Anmelden",
        "logout": "Abmelden",
        "home": "Startseite",
        "architecture": "Architektur",
        "business": "Business",
        "data": "Daten",
        "solutions": "Lösungen",
        "technology": "Technologie",
        "contact": "Kontakt",   
        "settings": "Einstellungen"
    ]
];

string[string] getTranslations(string lang) {
    string langCode = (lang in dictionary) ? lang : "en";
    return dictionary[langCode];
}

string translate(string lang, string key) {
    string langCode = (lang in dictionary) ? lang : "en";
    return (key in dictionary[langCode]) ? dictionary[langCode][key] : key;
}