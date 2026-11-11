# Mission

## Zweck

Die Sandbox ist eine **sichere Umgebung für KI-Coding-Agenten**. Agenten wie
opencode und Claude Code sollen darin selbstständig und gefahrlos am Code
arbeiten können: lesen, ändern, bauen, testen, committen und Pull Requests
öffnen, ohne dass sie den Host, fremde Daten oder Zugangsdaten über das
Nötige hinaus erreichen.

Der Quellcode bleibt auf dem Rechner der Nutzerin oder des Nutzers. Im
Container laufen nur die Werkzeugkette und die Agenten. Was ein Agent sehen,
erreichen und tun darf, ist ausdrücklich festgelegt und lässt sich überprüfen.

## Zielgruppe

1. **Ich selbst:** ein einzelner Entwickler auf dem eigenen Rechner.
2. **Das Entwickler-Team:** Kolleginnen und Kollegen, die dieselbe Sandbox auf
   macOS, Linux oder Windows nutzen und sich auf dieselben Sicherheitszusagen
   verlassen wollen.

## Leitprinzipien

Bei Zielkonflikten gilt die Reihenfolge der Liste.

1. **Sicherheit und Isolation zuerst.** Im Zweifel gibt es eine Einschränkung
   mehr. Ein Leck nach außen, etwa übers Netz, über Secrets oder über das
   Host-Dateisystem, wiegt schwerer als ein fehlender Komfort. Jede
   Lockerung ist ein bewusster, dokumentierter Schalter in der `.env`.
2. **Gleichberechtigte Agenten.** opencode und Claude Code bekommen dieselben
   Befehle, dieselben Regeln und dieselben Werkzeuge aus *einer* Quelle unter
   `config/`. Kein Feature und keine Sicherheitsregel gilt nur für einen
   der beiden.
3. **Gleichstand der Plattformen.** `sandbox.sh` (macOS/Linux) und `sandbox.ps1`
   (Windows) können dasselbe. Eine Änderung gilt erst als fertig, wenn sie auf
   beiden Wegen funktioniert.

Daneben gilt, auch ohne Vorrangregel: Jede Sicherheitszusage muss
**überprüfbar** sein, im Idealfall automatisch über `./sandbox.sh doctor`.

## Nicht-Ziele

- **Kein Produktiv-Hosting.** Die Sandbox ist eine Entwicklungsumgebung. Sie
  ist kein Deployment-Ziel und kein Laufzeitsystem für Anwendungen.

## Arbeitsweise

Das Projekt wird **spec-driven** weiterentwickelt:

1. `specs/mission.md` (diese Datei): warum und für wen.
2. `specs/requirements.md`: was gelten muss, mit nummerierten, prüfbaren
   Anforderungen.
3. `specs/roadmap.md`: in welcher Reihenfolge umgesetzt wird. Jeder Schritt
   entspricht einem kleinen Pull Request und wird nach dem Merge abgehakt.
4. `specs/validation.md`: wie geprüft wird, mit nummerierten Prüfschritten,
   auf die Schrittpläne und Pull Requests verweisen.

Ändert sich die Richtung, wird zuerst die Spec angepasst und danach der Code.
