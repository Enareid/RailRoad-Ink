# scripts

Ce scripts bash a pour objectif de lancer une série de programmes nécessaires à l'exécution du jeu en ligne.
Il s'assure que les dépendances node sont installées et suit un ordre précis pour le bon fonctionnement des services.

Pour lancer le script a la racine du dépot voici les commandes : 
```
chmod +x linux_start.sh
./linux_start.sh
```

1. Installation des dépendances 
    - Avant de démarrer les services, le script vérifie que les dossier `node_modules` existent dans `web_game_displayer` et `railroad`
    - Si ces dossier sont absents, on exécute la commande `npm install` pour installer les dépendances nécessaires
2. Lancement du server de jeu - Web Game Displayer
    - Le script démarre `nodemon` dans `web_game_displayer` afin d'ouvrir le server de jeu.
    - les logs sont enregistrés dans `nodemon.log`
3. Récupération de l'ip du server
    - Après quelques secondes, le script extrait l'ip du server depuis le fichier log.
    - Si l'ip ne peut pas être récupérée le script s'arrête
4. Lancement du Reflector
    - Une fois l'ip obtenue, `reflector` est lancé dans `reflector-linux-x64` avec cette adresse.
    - Ses logs sont enregistrés dans `reflector.log`
5. Récupération du port WebSocket du Reflector
    - Après quelques secondes, le script extrait le port WebSocket utilisé par `reflector` depuis ses logs
    - SI le port ne peut pas être récupéré, le script s'arrête
6. Lancement du client save
    - Lancement d'un client permettant de sauvegarder la partie 
7. Lancement de l'arbitre - Railroad
    - `referee.js` est exécuté vie Node.js avec l'option `--watch` pour recharger le programme en cas de modification.
    - Ler logs sont enregistrés dans `railroad.log`
8. Lancement du spéctateur - spectate
    - nodemon lance le spectateur
    - Le spectateur ne peut pas jouer mais affiche les plateau de tous le joueur, et les met a jour en direct.
9. Pause de 60 secondes
    - Cette pause est nécessaire pour plusieurs raison, on s'assure que tous les services précédents sont bien démarrés, et on permet au joueur une minutes pour se connecté au client web.
10. Lancement de GameMaster
    - `GameMaster.hs` est exécuté avec l'ip et le port récupérés précédemment