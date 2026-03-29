# PMTMiniApp-Dev-Tools

Depot separe pour `PMTMiniApp Dev Tools` sur Linux.

## Installation simple

Pour un utilisateur final, le plus simple est :

1. ouvrir la page `Releases` du depot
2. telecharger le fichier `.deb`
3. double-cliquer sur le fichier telecharge
4. cliquer sur `Installer`

Apres installation :

- l'application apparait dans le menu sous `PMTMiniApp Dev Tools`
- un raccourci Bureau est cree

Si Ubuntu affiche un `X` rouge sur le raccourci Bureau :

1. faites clic droit sur le raccourci
2. choisissez `Autoriser le lancement`

## Installation manuelle en ligne de commande

Si le double-clic ne marche pas, utilisez :

```bash
sudo apt install ./pmtminiapp-dev-tools_2.01.2510290-1_amd64.deb
```

## Framework recommande pour demarrer vite

Le framework recommande pour un developpement rapide, simple et complet est :

- depot principal : `https://github.com/MalickDevWeb/PMTMiniApp-Framwork`
- generateur recommande pour aller le plus vite : `https://github.com/MalickDevWeb/PMTMiniApp-Framwork/tree/main/create-pmt-miniapp`

La methode la plus simple :

1. installez `PMTMiniApp Dev Tools`
2. ouvrez le depot framework `PMTMiniApp-Framwork`
3. utilisez `create-pmt-miniapp` pour generer un projet

## Contenu du depot

Ce depot contient :

- l'image du raccourci Bureau
- un modele `.desktop`
- un script d'installation Linux
- un systeme de build pour creer un vrai paquet `.deb`

## Fichiers

- `assets/orange.png` : image du raccourci
- `desktop/PMTMiniApp Dev Tools.desktop.template` : modele du lanceur
- `scripts/install-linux.sh` : installateur
- `scripts/build-deb.sh` : build du paquet `.deb`
- `packaging/` : templates Debian

## Installation depuis les scripts du depot

```bash
chmod +x scripts/install-linux.sh
./scripts/install-linux.sh
```

## Creer un vrai fichier .deb

Pour publier un installateur Linux a telecharger puis ouvrir au double-clic :

```bash
chmod +x scripts/build-deb.sh
./scripts/build-deb.sh
```

Le fichier genere sera dans :

```text
dist/pmtminiapp-dev-tools_2.01.2510290-1_amd64.deb
```

Ensuite, pour publier sur GitHub :

1. allez dans `GitHub Releases`
2. ajoutez ce fichier `.deb`
3. les utilisateurs pourront le telecharger
4. sur Ubuntu, un double-clic ouvrira l'installateur de paquets

## Resultat apres installation

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
- le paquet `.deb` cree une entree menu et copie aussi un raccourci Bureau pour les utilisateurs existants
- Si Ubuntu affiche un `X` rouge sur le raccourci Bureau, faites `clic droit > Autoriser le lancement`
