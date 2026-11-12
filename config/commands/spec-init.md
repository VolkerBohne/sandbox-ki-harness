---
description: Die Spec-Dateien mission.md, requirements.md und roadmap.md fuer ein Projekt anlegen, mit einer Fragerunde je Datei
---

Du legst fuer das aktuelle Projekt die Spec-Dateien fuer Spec-Driven
Development an: `specs/mission.md`, `specs/requirements.md` und
`specs/roadmap.md`. Es wird **kein Code geaendert**, nichts committet und kein
Branch angelegt.

## Projekt

$ARGUMENTS

Optional: eine Kurzbeschreibung des Projekts. Fehlt sie, ermittelst du, was
sich nachlesen laesst, und fragst den Rest in den Fragerunden ab.

## Schritt 0: Kontext ermitteln

Fuehre das zuerst aus und verwende die Ausgabe in allen weiteren Schritten:

```sh
echo "Verzeichnis: $(pwd)"
echo "Repository:  $(git remote get-url origin 2>/dev/null || echo 'kein Git-Repository')"
echo "Branch:      $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-')"
for f in mission requirements roadmap; do
  if [ -f "specs/$f.md" ]; then echo "specs/$f.md: vorhanden"; else echo "specs/$f.md: fehlt"; fi
done
```

## Vorgehen

1. **Vorhandene Specs pruefen.**
   - Liegen alle drei Dateien vor, melde das und beende den Befehl ohne
     Aenderung. Weise auf `/spec-plan` als naechsten Befehl hin.
   - Liegen einige vor, nenne sie. Sie bleiben **unveraendert**. Lies sie als
     Kontext und lege nur die fehlenden an.

2. **Projekt erkunden.** Lies, was es gibt: README, weitere Dokumentation,
   Build- und Paketdateien wie `Makefile`, `package.json`, `go.mod`,
   `pyproject.toml`, `Cargo.toml`, `pom.xml`, `build.gradle`, `*.csproj` und
   CI-Konfiguration. Setze kein bestimmtes Werkzeug und keine bestimmte
   Sprache voraus. Frage spaeter nur, was sich nicht nachlesen laesst.

3. **Sprache der Specs festlegen.** Die Spec-Dateien werden in der Sprache des
   Projekts geschrieben. Leite sie aus README und vorhandener Dokumentation
   ab. Ist sie nicht eindeutig, etwa bei einem leeren Projekt, nimm die Frage
   danach in die **erste** Fragerunde auf. Sie bekommt keine eigene Runde.

4. **Fragerunden: genau eine je fehlender Datei.** Stelle die Fragen einer
   Runde gesammelt in **einer** Nachricht, nummeriert und nach Themen
   gruppiert. Warte dann auf die Antwort. Schlage, wo moeglich, eine Antwort
   aus dem vor, was du schon weisst, sodass eine kurze Bestaetigung reicht.
   Stelle innerhalb einer Runde keine Nachfragen. Was offen bleibt, schreibst
   du als offene Frage in die Datei.

   Reihenfolge der Runden. Die Runde einer vorhandenen Datei entfaellt:

   1. *mission.md:* Zweck des Projekts, Zielgruppe, Leitprinzipien mit
      Rangfolge bei Zielkonflikten, Nicht-Ziele.
   2. *requirements.md:* Themenbereiche, Querschnittsregeln fuer alle
      Anforderungen, bekannte Anforderungen je Bereich mit Verbindlichkeit
      (MUSS, SOLL, KANN), Ausgangslage je Bereich.
   3. *roadmap.md:* Phasen und ihre Reihenfolge, die ersten Schritte,
      Akzeptanzkriterien und wie man sie prueft, Ideen fuer spaeter.

5. **Datei direkt nach ihrer Runde schreiben.** Schreibe jede Datei, sobald
   ihre Antworten da sind, und zeige kurz, was entstanden ist. Die naechste
   Runde baut auf dem Geschriebenen auf.

6. **Zusammenfassung.** Liste die angelegten und die unveraenderten Dateien
   auf. Schliesse mit dem Hinweis, dass `/spec-plan` den ersten offenen
   Roadmap-Schritt plant.

## Aufbau der Dateien

Die Ueberschriften stehen hier auf Deutsch. Schreibe sie in der Sprache des
Projekts.

**`specs/mission.md`**

- `# Mission`
- `## Zweck`: warum es das Projekt gibt, zwei bis vier Absaetze
- `## Zielgruppe`: nummerierte Liste
- `## Leitprinzipien`: nummeriert. Die Reihenfolge entscheidet bei
  Zielkonflikten, das steht als Satz davor.
- `## Nicht-Ziele`: Liste
- `## Arbeitsweise`: Das Projekt wird spec-driven weiterentwickelt. Nenne die
  drei Dateien mit ihrem Zweck und die Regel: Aendert sich die Richtung, wird
  zuerst die Spec angepasst und danach der Code.

**`specs/requirements.md`**

- `# Anforderungen`
- Einleitung mit den Regeln: Jede Anforderung hat eine feste ID. Roadmap,
  Commits und Pull Requests verweisen darauf. Geaenderte Anforderungen
  behalten ihre ID, weggefallene werden als *entfallen* markiert und nicht
  geloescht. Verbindlichkeit: **MUSS**, **SOLL**, **KANN**.
- Querschnittsregeln als Liste mit IDs `X-1`, `X-2`, ...
- Je Bereich ein Abschnitt `## <n>. <Bereich>` mit einem Satz zur
  Ausgangslage und einer Tabelle:

  ```markdown
  | ID | Anforderung | Stufe |
  |----|-------------|-------|
  | ABC-1 | ... | MUSS |
  ```

  Das Praefix der ID ist ein kurzes Kuerzel des Bereichs in Grossbuchstaben.
  Jede Anforderung ist einzeln pruefbar formuliert.

**`specs/roadmap.md`**

- `# Roadmap`
- Einleitung: Ein Schritt entspricht einem kleinen Pull Request und wird nach
  dem Merge abgehakt. Jeder Schritt nennt *Anf.*, *Fertig, wenn* und
  *Pruefen*.
- Je Phase `## Phase <n>: <Titel>`, darin Schritte im Format:

  ```markdown
  - [ ] **R1.1 <Titel>**
    <ein bis zwei Saetze, was entsteht>
    *Anf.:* ABC-1, X-1
    *Fertig, wenn:* <Akzeptanzkriterien>
    *Pruefen:* <Befehl oder Vorgehen>
  ```

  Die Nummer ist `R<Phase>.<Schritt>`. Jeder Schritt verweist auf mindestens
  eine ID aus `requirements.md`. Ist eine der beiden Dateien schon vorhanden,
  verwende deren IDs und erfinde keine neuen.
- Am Ende `## Spaeter / ungeplant`: Ideen, die erst nach einer Anpassung von
  `requirements.md` eingeplant werden.

## Regeln

- Aendere nichts ausserhalb von `specs/`, und vorhandene Spec-Dateien gar
  nicht. Keine Commits, keine Branches, keine Pull Requests.
- Genau eine Fragerunde je anzulegender Datei, keine weiteren Rueckfragen.
- Erfinde keine Anforderungen, die weder aus den Antworten noch aus dem
  Projekt folgen. Was unklar bleibt, steht in der Datei als offene Frage.
- Rueckfragen und Zusammenfassung auf Deutsch. Die Spec-Dateien in der
  Sprache des Projekts.
