SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_GAME_PATH="$SCRIPT_DIR/web_game_displayer"

cd "$WEB_GAME_PATH" || exit
echo "Lancement de nodemon..."
nodemon | tee nodemon.log &
NPM_PID=$!


wait $NPM_PID