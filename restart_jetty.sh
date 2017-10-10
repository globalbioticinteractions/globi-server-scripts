#!/bin/bash
source ~/.profile

JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"
JETTY_PID="$JETTY_DIR/jetty.pid"
PID=$(cat "$JETTY_PID" 2>/dev/null)
kill "$PID" 2>/dev/null

cd "$GLOBI_HOME"
echo jetty rebuilding...
mvn clean install -pl eol-globi-rest,eol-globi-lib -DskipTests 

echo jetty starting...
nohup java -Dneo4j.cypher.uri="http://localhost:7476/db/data/cypher" -jar $JETTY_DIR/dependency/jetty-runner.jar --port 8080 $JETTY_DIR/*.war > /home/jhpoelen/eol-globi-rest.log &
echo $! > "$JETTY_PID"
echo jetty started.


