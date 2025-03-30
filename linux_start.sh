#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_GAME_PATH="$SCRIPT_DIR/web_game_displayer"

REFLECTOR_DIR=$(ls | grep "reflector")

REFLECTOR_PATH="$SCRIPT_DIR/$REFLECTOR_DIR"
SPECTATOR_PATH="$SCRIPT_DIR/spectate"
SAVE_REPLAY_PATH="$SCRIPT_DIR/save_replay_client"
REPLAY_PATH="$SCRIPT_DIR/save_replay_client"

MODE="normal"
REPLAY_FILE=""

# Vérification des arguments
if [[ "$1" == "--replay" ]]; then
    MODE="replay"
    REPLAY_FILE="$2"
    if [[ -z "$REPLAY_FILE" ]]; then
        echo "Erreur : Vous devez spécifier un fichier de replay."
        exit 1
    fi
fi

check_and_install_npm() {
    local dir="$1"
    if [ ! -d "$dir/node_modules" ]; then
        echo "Dossier node_modules introuvable dans $dir, exécution de npm install..."
        cd "$dir" || exit
        npm install
        sleep 5
    fi
}

if [[ "$MODE" == "normal" ]]; then
    check_and_install_npm "$WEB_GAME_PATH"
    check_and_install_npm "$SCRIPT_DIR/railroad"
    check_and_install_npm "$SPECTATOR_PATH"

    cd "$WEB_GAME_PATH" || exit
    echo "Lancement de nodemon..."
    nodemon | tee nodemon.log &
    NPM_PID=$!

    sleep 3

    IP=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' nodemon.log | head -n 1)
else
    IP=$(hostname -I | awk '{print $1}')
fi

if [[ -z "$IP" ]]; then
    echo "Impossible de récupérer l'adresse IP."
    exit 1
fi

echo "Adresse IP récupérée : $IP"

cd "$REFLECTOR_PATH" || exit
echo "Lancement de Reflector avec l'adresse IP : $IP..."
./reflector --host "$IP" | tee reflector.log &
REFLECTOR_PID=$!

sleep 3

PORT=$(grep -oE 'ws://[^:]+:[0-9]+' reflector.log | grep -oE '[0-9]+$')

if [[ -z "$PORT" ]]; then
    echo "Impossible de récupérer le port du Reflector."
    exit 1
fi

echo "Port récupéré : $PORT"

if [[ "$MODE" == "replay" ]]; then
    cd "$REPLAY_PATH" || exit
    echo "Exécution de replay.py avec le fichier : $REPLAY_FILE, l'adresse IP : $IP et le port : $PORT..."
    python3 replay.py "$REPLAY_FILE" "$IP" "$PORT" &
    REPLAY_PID=$!

    cd "$SPECTATOR_PATH" || exit
    echo "Lancement du spectateur..."
    nodemon | tee spectator.log &
    SPECTATOR_PID=$!

    wait $REFLECTOR_PID $REPLAY_PID $SPECTATOR_PID
    exit 0
fi

cd "$SAVE_REPLAY_PATH" || exit
echo "Exécution de save.py avec l'adresse IP : $IP et le port : $PORT..."
python3 save.py "$IP" "$PORT" &
SAVE_REPLAY_PID=$!

cd "$SCRIPT_DIR/railroad" || exit
echo "Lancement de l'arbitre..."
node --watch referee.js | tee railroad.log &
ARBITRE_PID=$!

sleep 3

cd "$SPECTATOR_PATH" || exit
echo "Lancement du spectateur..."
nodemon | tee spectator.log &
SPECTATOR_PID=$!

sleep 3

echo "Attente de 60 secondes avant de lancer GameMaster..."
sleep 60

cd "$SCRIPT_DIR/gamemaster" || exit
echo "Lancement de GameMaster avec l'adresse IP : $IP et le port : $PORT..."
runghc GameMaster.hs "$IP" "$PORT" &
GAMEMASTER_PID=$!

wait $NPM_PID $REFLECTOR_PID $SAVE_REPLAY_PID $ARBITRE_PID $SPECTATOR_PID $GAMEMASTER_PID
