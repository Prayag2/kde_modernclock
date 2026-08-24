# Notas de este fork

Este es un fork personal de
[Prayag2/kde_modernclock](https://github.com/Prayag2/kde_modernclock)
(ver `README.md` para la descripción del proyecto original). El
`README.md` de esta carpeta es el del autor original, sin tocar.

## Qué cambia en la rama `add-spanish-translation`

- **Traducción al español** del panel de configuración del widget
  (no tenía catálogo de traducción — se agregó).
- **Fix de bug de fecha**: el reloj mostraba el día/fecha en inglés
  incluso con el sistema en español, porque el código usaba la
  función global `Qt.formatDate(...)` con patrón de texto, que
  siempre usa el locale **C** fijo sin importar la configuración del
  sistema. Se cambió al método de instancia `date.toLocaleDateString(
  Qt.locale(), ...)`, que sí respeta el locale.

## Estado

PR abierto contra el repo original:
[Prayag2/kde_modernclock#26](https://github.com/Prayag2/kde_modernclock/pull/26).
