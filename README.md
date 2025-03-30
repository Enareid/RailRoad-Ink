# Scripts

## Play 

This bash script starts a set of programs necessary to execute the game online.
It makes sure that dependencies are installed before starting each element in a precise order. 

To start the script, execute these commands at the root of the directory : 
```
chmod +x linux_start.sh
./linux_start.sh
```

1. Dependence installation
    - Before starting services, the script check for `node_modules` files 
    - If those files does not exist, it runs `npm install` command
2. Game server start - Web Game Displayer
    - The script start `nodemon` in `web_game_displayer` to open the game server
    - Logs are saved in `nodemon.log`
3. Get server IP address
    - After a few seconds the script gets the server IP address from log file
    - If it does not succeed, the script stops
4. Start of Reflector
    - Once the script got the IP address, `reflector` starts in `reflector-linux-x64` with this IP address
    - Logs are saved in `reflector.log`
5. Get port of Reflector websocket
    -  After a few seconds the script gets the server websocket port used by `reflector` from logs
    - If it does not succeed, the script stops
6. Client save start
    - Start of a client that will save the game
7. Start referee - Railroad
    - `referee.js` is executed via Node.Js with `--watch` option.
    - Logs are saved in `railroad.log`
8. Start spectator - spectate
    - nodemon starts spectate
    - Spectator can not play but displays all board and update them live
9. 60 seconds break
    - This break is used to allow player to connect before starting GameMaster
10. Start GameMaster
    - `GameMaster.hs` is executed

You can access the page at the following address :
```
IPAddress:9000/
```
Where IPAddress, is the IP address of your machine.

## Watch a game

In order to watch a game that has already been played, you can start the script with the following command :
```
./linux_start.sh --replay <file>
```

Where file is a log file containing reflector messages.

Here is what the script does when this option is activated : 
1. Dependence installation
    - Before starting services, the script check for `node_modules` files 
    - If those files does not exist, it runs `npm install` command
2. Start of Reflector
    - Get IP address with `hostname -I` command
    - Once the script got the IP address, `reflector` starts in `reflector-linux-x64` with this IP address
    - Logs are saved in `reflector.log`
3. Start replay client
    - Start a client that allows a game to be replayed
    - Get file passed in option
4. Start spectator - spectate
    - nodemon starts spectate
    - Spectator can not play but displays all board and update them live

You can access the page at the following address :
```
IPAddress:9090/src/index.html
```
Where IPAddress, is the IP address of your machine.