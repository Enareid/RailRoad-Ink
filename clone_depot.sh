#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_GAME_PATH="$SCRIPT_DIR/web_game_displayer"
GAMEMASTER_PATH="$SCRIPT_DIR/gamemaster"
SPECTATOR_PATH="$SCRIPT_DIR/spectate"
SAVE_REPLAY_PATH="$SCRIPT_DIR/save_replay_client"
RAILROAD_PATH="$SCRIPT_DIR/railroad"

check_and_clone_repo() {
    local dir="$1"
    local repo="$2"
    if [ ! -d "$dir" ]; then
        echo "Dossier $dir introuvable, clonage du dépôt..."
        git clone "$repo" "$dir"
        if [ $? -ne 0 ]; then
            echo "Erreur lors du clonage du dépôt $repo. Vérifiez votre connexion et assurez-vous d'être connecté au VPN de l'université de Lille."
            exit 1
        fi
    fi
}

# Vérification et clonage des dépôts si nécessaire
check_and_clone_repo "$SPECTATOR_PATH" "git@github.com:Enareid/spectate.git"
check_and_clone_repo "$WEB_GAME_PATH" "git@github.com:Enareid/Web_Game_Displayer.git"
check_and_clone_repo "$GAMEMASTER_PATH" "git@github.com:Enareid/GameMaster.git"
check_and_clone_repo "$SAVE_REPLAY_PATH" "git@github.com:Enareid/save_replay_client.git"
check_and_clone_repo "$RAILROAD_PATH" "git@github.com:Enareid/railroad_logical.git"

echo "Tous les dépôts sont clonés avec succès."
