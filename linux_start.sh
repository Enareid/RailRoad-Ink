SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_GAME_PATH="$SCRIPT_DIR/web_game_displayer"

REFLECTOR_DIR=$(ls | grep "reflector")

REFLECTOR_PATH="$SCRIPT_DIR/$REFLECTOR_DIR"
RAILROAD_PATH="$SCRIPT_DIR/railroad"
GAMEMASTER_PATH="$SCRIPT_DIR/gamemaster"

check_and_install_npm() {
    local dir="$1"
    if [ ! -d "$dir/node_modules" ]; then
        echo "Dossier node_modules introuvable dans $dir, exécution de npm install..."
        cd "$dir" || exit
        npm install
        sleep 5
    fi
}

check_and_install_npm "$WEB_GAME_PATH"
check_and_install_npm "$RAILROAD_PATH"

cd "$WEB_GAME_PATH" || exit
echo "Lancement de nodemon..."
nodemon | tee nodemon.log &
NPM_PID=$!

sleep 3

IP=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' nodemon.log | head -n 1)

if [[ -z "$IP" ]]; then
    echo "Impossible de récupérer l'adresse IP depuis nodemon."
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

cd "$RAILROAD_PATH" || exit
echo "Lancement de l'arbitre..."
node --watch referee.js | tee railroad.log &
ARBITRE_PID=$!

sleep 3

echo "Attente de 60 secondes avant de lancer GameMaster..."
sleep 60

cd "$GAMEMASTER_PATH" || exit
echo "Lancement de GameMaster avec l'adresse IP : $IP et le port : $PORT..."
runghc GameMaster.hs "$IP" "$PORT" &
GAMEMASTER_PID=$!

wait $NPM_PID $REFLECTOR_PID $ARBITRE_PID $GAMEMASTER_PID
