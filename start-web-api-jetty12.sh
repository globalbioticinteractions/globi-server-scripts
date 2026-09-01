#!/bin/bash
JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"

NEO4J_PORT=7474
NEO4J_HOST=localhost

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
mvn clean install -pl eol-globi-rest -am --settings /etc/globi/.m2/settings.xml -DskipTests

echo jetty starting...
cd eol-globi-rest
mvn jetty:run --settings /etc/globi/.m2/settings.xml
