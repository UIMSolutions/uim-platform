/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Deterministic in-process translation engine. It stands in for SAP MLTR,
/// neural MT and the generative AI hub until real HTTP clients are bound:
/// a small terminology dictionary is applied word by word (case kept), words
/// it does not know are kept and tagged with the target language.
module uim.platform.translation.infrastructure.clients.simulated_provider;

import std.ascii : isAlpha, isUpper, toUpper, toLower;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

class SimulatedTranslationProvider : ITranslationProviderGateway {
  protected TranslationProvider[] enabled;
  /// Recorded requests (tests, diagnostics).
  string[] requests;

  this(TranslationProvider[] enabled = [TranslationProvider.mltr, TranslationProvider.machineMt,
      TranslationProvider.companyMltr, TranslationProvider.llm]) {
    this.enabled = enabled;
  }

  bool available(TranslationProvider provider) {
    return enabled.canFind(provider);
  }

  ProviderTranslation translate(string text, string sourceLanguage, string targetLanguage,
      TranslationProvider provider, string domainName, TextType textType) {
    requests ~= enumText(provider) ~ ":" ~ sourceLanguage ~ "→" ~ targetLanguage;
    auto from = primaryLanguage(sourceLanguage), to = primaryLanguage(targetLanguage);
    auto words = dictionaryFor(from, to);

    // tokenize into words and separators; placeholders (⟦n⟧) are separators
    string result;
    size_t known, unknown, i;
    while (i < text.length) {
      if (!isAlpha(text[i])) {
        result ~= text[i];
        i++;
        continue;
      }
      auto start = i;
      while (i < text.length && (isAlpha(text[i]) || text[i] == '\''))
        i++;
      auto word = text[start .. i];
      if (auto t = lowerWord(word) in words) {
        result ~= matchCase(word, *t);
        known++;
      } else {
        result ~= word;
        unknown++;
      }
    }
    if (known == 0 && unknown > 0 && from != to && text.indexOf("⟦") < 0)
      result = "[" ~ to ~ "] " ~ result;

    ProviderTranslation r;
    r.text = result;
    auto total = known + unknown;
    auto coverage = total == 0 ? 1.0 : cast(double) known / total;
    r.qualityScore = cast(int)(baseScore(provider) - 25 * (1.0 - coverage) + 0.5);
    return r;
  }

  /// Engine estimate for fully known text.
  static int baseScore(TranslationProvider provider) pure nothrow {
    final switch (provider) {
    case TranslationProvider.mltr:
      return 96;
    case TranslationProvider.companyMltr:
      return 93;
    case TranslationProvider.llm:
      return 90;
    case TranslationProvider.machineMt:
      return 85;
    }
  }

  protected static string lowerWord(string w) {
    string s;
    foreach (char c; w)
      s ~= toLower(c);
    return s;
  }

  /// "SAVE" → "SPEICHERN", "Save" → "Speichern", "save" → "speichern".
  protected static string matchCase(string original, string translated) {
    if (translated.length == 0)
      return translated;
    bool allUpper = original.length > 1;
    foreach (char c; original)
      if (isAlpha(c) && !isUpper(c))
        allUpper = false;
    if (allUpper) {
      string s;
      foreach (char c; translated)
        s ~= toUpper(c);
      return s;
    }
    if (isUpper(original[0]) && translated[0] < 0x80)
      return cast(char) toUpper(translated[0]) ~ translated[1 .. $];
    return translated;
  }

  protected static const(string[string]) dictionaryFor(string from, string to) {
    if (from != "en")
      return null;
    switch (to) {
    case "de":
      return dictionaryDe;
    case "fr":
      return dictionaryFr;
    case "es":
      return dictionaryEs;
    case "it":
      return dictionaryIt;
    default:
      return null;
    }
  }
}

private immutable string[string] dictionaryDe;
private immutable string[string] dictionaryFr;
private immutable string[string] dictionaryEs;
private immutable string[string] dictionaryIt;

shared static this() {
  // en → de / fr / es / it: frequent UI and business terms
  static immutable string[5][] rows = [
    ["save", "speichern", "enregistrer", "guardar", "salva"],
    ["cancel", "abbrechen", "annuler", "cancelar", "annulla"],
    ["delete", "löschen", "supprimer", "eliminar", "elimina"],
    ["edit", "bearbeiten", "modifier", "editar", "modifica"],
    ["create", "anlegen", "créer", "crear", "crea"],
    ["new", "neu", "nouveau", "nuevo", "nuovo"],
    ["open", "öffnen", "ouvrir", "abrir", "apri"],
    ["close", "schließen", "fermer", "cerrar", "chiudi"],
    ["search", "suchen", "rechercher", "buscar", "cerca"],
    ["settings", "einstellungen", "paramètres", "configuración", "impostazioni"],
    ["user", "benutzer", "utilisateur", "usuario", "utente"],
    ["name", "name", "nom", "nombre", "nome"],
    ["customer", "kunde", "client", "cliente", "cliente"],
    ["order", "auftrag", "commande", "pedido", "ordine"],
    ["invoice", "rechnung", "facture", "factura", "fattura"],
    ["payment", "zahlung", "paiement", "pago", "pagamento"],
    ["date", "datum", "date", "fecha", "data"],
    ["amount", "betrag", "montant", "importe", "importo"],
    ["price", "preis", "prix", "precio", "prezzo"],
    ["product", "produkt", "produit", "producto", "prodotto"],
    ["error", "fehler", "erreur", "error", "errore"],
    ["warning", "warnung", "avertissement", "advertencia", "avviso"],
    ["file", "datei", "fichier", "archivo", "file"],
    ["not", "nicht", "pas", "no", "non"],
    ["found", "gefunden", "trouvé", "encontrado", "trovato"],
    ["the", "der", "le", "el", "il"],
    ["and", "und", "et", "y", "e"],
    ["or", "oder", "ou", "o", "o"],
    ["please", "bitte", "veuillez", "por favor", "per favore"],
    ["enter", "eingeben", "saisir", "introducir", "inserisci"],
    ["welcome", "willkommen", "bienvenue", "bienvenido", "benvenuto"],
    ["yes", "ja", "oui", "sí", "sì"],
    ["no", "nein", "non", "no", "no"],
    ["back", "zurück", "retour", "atrás", "indietro"],
    ["next", "weiter", "suivant", "siguiente", "avanti"],
    ["submit", "absenden", "envoyer", "enviar", "invia"],
    ["password", "kennwort", "mot de passe", "contraseña", "password"],
    ["email", "e-mail", "e-mail", "correo", "e-mail"],
    ["address", "adresse", "adresse", "dirección", "indirizzo"],
    ["status", "status", "statut", "estado", "stato"],
    ["report", "bericht", "rapport", "informe", "report"],
    ["sales", "vertrieb", "ventes", "ventas", "vendite"],
    ["employee", "mitarbeiter", "employé", "empleado", "dipendente"],
    ["account", "konto", "compte", "cuenta", "conto"],
    ["total", "gesamt", "total", "total", "totale"],
    ["is", "ist", "est", "es", "è"],
    ["required", "erforderlich", "obligatoire", "obligatorio", "obbligatorio"],
    ["field", "feld", "champ", "campo", "campo"],
    ["changes", "änderungen", "modifications", "cambios", "modifiche"],
    ["your", "ihre", "vos", "sus", "le tue"],
  ];
  string[string] de, fr, es, it;
  foreach (r; rows) {
    de[r[0]] = r[1];
    fr[r[0]] = r[2];
    es[r[0]] = r[3];
    it[r[0]] = r[4];
  }
  dictionaryDe = (() @trusted => cast(immutable) de)();
  dictionaryFr = (() @trusted => cast(immutable) fr)();
  dictionaryEs = (() @trusted => cast(immutable) es)();
  dictionaryIt = (() @trusted => cast(immutable) it)();
}

///
unittest {
  mixin(ShowTest!("SimulatedTranslationProvider"));

  auto p = new SimulatedTranslationProvider();
  auto r = p.translate("Save", "en", "de", TranslationProvider.machineMt, "", TextType.uiText);
  assert(r.text == "Speichern" && r.qualityScore == 85, r.text);
  assert(p.translate("SAVE changes", "en", "de", TranslationProvider.mltr, "", TextType.uiText).text == "SPEICHERN änderungen");
  // placeholders and punctuation survive
  assert(p.translate("Post ⟦0⟧ now!", "en", "fr", TranslationProvider.llm, "", TextType.uiText).text == "Post ⟦0⟧ now!");
  assert(p.translate("Hello", "en", "ja", TranslationProvider.machineMt, "", TextType.uiText).text == "[ja] Hello");
  assert(p.translate("Hello", "en", "ja", TranslationProvider.machineMt, "", TextType.uiText).qualityScore == 60);
  assert(!new SimulatedTranslationProvider([TranslationProvider.mltr]).available(TranslationProvider.llm));
}
