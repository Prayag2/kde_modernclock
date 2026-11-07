<p align="center">
  <img src="https://github.com/citizenserious/kde_modernclock/blob/main/assets/logo.jpg" width=100/>
  <h2 align="center">Modern Clock for KDE</h2>
  <p align="center">A modern looking clock widget!</p>
</p>

<p align="center">
<a href="https://github.com/citizenserious/kde_modernclock/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/citizenserious/kde_modernclock?color=%233DAEE9&style=for-the-badge"></a>
<a href="https://github.com/citizenserious/kde_modernclock/network"><img alt="GitHub forks" src="https://img.shields.io/github/forks/citizenserious/kde_modernclock?color=%233DAEE9&style=for-the-badge"></a>
<a href="https://github.com/citizenserious/kde_modernclock/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/citizenserious/kde_modernclock?color=%233DAEE9&style=for-the-badge"></a>
</p>

<p align="center">
  <img src="https://github.com/citizenserious/kde_modernclock/blob/main/assets/ss.png"/>
</p>

## Installation
#### KDE Store (Preferred way)
1. Right click on the desktop
2. Click on "Add Widgets"
3. Click on "Get New Widgets"
4. Click on "Download New Plasma Widgets"
5. Search for "Modern Clock"
6. Click on "Install" and you're done!

#### From this repository
1. Clone this repository  
`git clone https://github.com/citizenserious/kde_modernclock && cd kde_modernclock/`  
2. Install using the script  
`kpackagetool6 -i package`

<!-- citizenserious Plasma 6 enhancements -->
## Plasma 6 enhancements

- **Click-through** (Appearance): optionally pass both left and right clicks
  to the desktop. Enter Plasma edit mode to move or configure the clock.
  Click-through is disabled by default; it is only applied to desktop applets.
- **Follow system text color**: automatically adapt clock text to the
  current light/dark Plasma theme, or use manual colors.
- **Localized date names**: correct day and month names for the system locale,
  including recent Qt 6 versions. Date patterns support d/dd/ddd/dddd,
  M/MM/MMM/MMMM and y/yy/yyyy, and quoted literals.
- **Custom font families**: enter an installed font family for day, date and
  time; leave the field blank to use the bundled default font.

For a locally installed copy, update with `kpackagetool6 -u package` from
this repository's root. Restart Plasma Shell if it still shows cached QML:
`systemctl --user restart plasma-plasmashell.service`.
