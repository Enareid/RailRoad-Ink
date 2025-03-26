SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_GAME_PATH="$SCRIPT_DIR/web_game_displayer"
REFLECTOR_PATH="$SCRIPT_DIR/reflector-linux-x64"

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


wait $NPM_PID $REFLECTOR_PID