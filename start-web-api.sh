#!/bin/bash
JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"

cd "$GLOBI_HOME"
echo updating git ...
git pull --rebase

echo jetty rebuilding...
mvn clean package -pl eol-globi-rest -am -DskipTests 

echo jetty starting...
java -Dneo4j.cypher.uri="http://localhost:7476/db/data/cypher" -jar $JETTY_DIR/dependency/jetty-runner.jar --port 8080 --host localhost $JETTY_DIR/*.war 


