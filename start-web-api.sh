#!/bin/bash
JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"

NEO4J_PORT=7474

# set specific version of GloBI indexer to use
#COMMIT_HASH=3c8cb8ec8fb5facb15b0f16f30afe524a9047583

cd "$GLOBI_HOME"
echo updating git ...
git pull --rebase

# checkout specific version if provided
if [ -n "$COMMIT_HASH" ]; then
  git checkout "$COMMIT_HASH"
fi

echo jetty rebuilding...
mvn clean package -pl eol-globi-rest -am --settings /etc/globi/.m2/settings.xml -DskipTests  

echo jetty starting...
java -Dneo4j.cypher.uri="http://localhost:${NEO4J_PORT}/db/data/transaction/commit" -jar $JETTY_DIR/dependency/jetty-runner.jar --port 8080 --host localhost $JETTY_DIR/*.war 


