#!/bin/bash
JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"

# set specific version of GloBI indexer to use
COMMIT_HASH=3c8cb8ec8fb5facb15b0f16f30afe524a9047583

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
java -Dneo4j.cypher.uri="http://localhost:7476/db/data/cypher" -jar $JETTY_DIR/dependency/jetty-runner.jar --port 8080 --host localhost $JETTY_DIR/*.war 


