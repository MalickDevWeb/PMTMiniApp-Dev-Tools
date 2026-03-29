# PMTMiniApp-Dev-Tools

Depot separe pour le lanceur Linux `PMTMiniApp Dev Tools`.

Ce depot contient :

- l'image du raccourci Bureau
- un modele `.desktop`
- un script d'installation Linux

## Fichiers

- `assets/orange.png` : image du raccourci
- `desktop/PMTMiniApp Dev Tools.desktop.template` : modele du lanceur
- `scripts/install-linux.sh` : installateur

## But

Quand quelqu'un telecharge ce depot et lance le script :

1. l'image est copiee dans le compte utilisateur
2. WeChat DevTools Linux est installe dans `~/Applications`
3. un lanceur menu est cree
4. un raccourci Bureau `PMTMiniApp Dev Tools.desktop` est cree

## Installation rapide

```bash
chmod +x scripts/install-linux.sh
./scripts/install-linux.sh
```

## Resultat

Le script cree :

- `~/Applications/run-pmtminiapp-dev-tools.sh`
- `~/.local/share/applications/pmtminiapp-dev-tools.desktop`
- `~/Bureau/PMTMiniApp Dev Tools.desktop` ou `~/Desktop/PMTMiniApp Dev Tools.desktop`

L'image est copiee ici :

- `~/.local/share/icons/hicolor/512x512/apps/pmtminiapp-dev-tools.png`

Le lanceur utilise l'icone nommee :

```ini
Icon=pmtminiapp-dev-tools
```

## Notes

- Le script installe la version Linux stable `2.01.2510290-1`
- Si Ubuntu affiche un `X` rouge sur le raccourci Bureau, faites `clic droit > Autoriser le lancement`
