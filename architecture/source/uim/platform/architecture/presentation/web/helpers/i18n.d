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
        "login": "Login",
        "logout": "Logout",
        "home": "Home",
        "architecture": "Architecture",
        "business": "Business",
        "data": "Data",
        "solutions": "Solutions",
        "technology": "Technology",
        "contact": "Contact",
        "settings": "Settings",
        "more": "More",
        "id": "Id",
        "name": "Name",
        "description": "Description",
        "title": "Title",
        "product": "Product",
        "module": "Module",
        "service": "Service",
        "version": "Version",
        "responsible": "Responsible",
        "capabilityProvided": "Capability Provided",
        "requiredInterfaces": "Required Interfaces"
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
        "settings": "Einstellungen",
        "more": "Weitere",
        "id": "Id",
        "name": "Name",
        "description": "Beschreibung",
        "title": "Bezeichnung",
        "product": "Produkt",
        "module": "Modul",
        "service": "Service",
        "version": "Version",
        "responsible": "Verantwortlich",
        "capabilityProvided": "Bereitgestellte Fähigkeit",
        "requiredInterfaces": "Erforderliche Schnittstellen"
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