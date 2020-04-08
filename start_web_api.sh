#!/bin/bash
source ~/.profile

JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"

cd "$GLOBI_HOME"
echo jetty rebuilding...
mvn clean install -pl eol-globi-rest -am -DskipTests 

echo jetty starting...
java -Dneo4j.cypher.uri="http://localhost:7476/db/data/cypher" -jar $JETTY_DIR/dependency/jetty-runner.jar --port 8080 $JETTY_DIR/*.war 


