#!/bin/bash
JETTY_HOME="$GLOBI_HOME/eol-globi-rest"
JETTY_DIR="$JETTY_HOME/target"

NEO4J_PORT=7477
NEO4J_HOST=localhost

# set specific version of GloBI indexer to use
# Aug 2026 commit on neo4j v3.5
+COMMIT_HASH=366437f6d7a845fed51f4a65dfcf2cb060725699

cd "$GLOBI_HOME"
echo updating git ...
git pull --rebase

# checkout specific version if provided
if [ -n "$COMMIT_HASH" ]; then
  git checkout "$COMMIT_HASH"
fi

echo jetty rebuilding...
mvn clean package -pl eol-globi-rest -am --settings /etc/globi/.m2/settings.xml -DskipTests  

if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=`which java`
else
  JAVACMD="$JAVA_HOME/bin/java"
fi

echo jetty starting...
cd eol-globi-rest 
mvn jetty:run --settings /etc/globi/.m2/settings-public.xml

#"${JAVACMD}" -Dneo4j.cypher.uri="http://${NEO4J_HOST}:${NEO4J_PORT}/db/data/transaction/commit" -jar $JETTY_DIR/dependency/jetty-runner.jar --port 8080 --host localhost $JETTY_DIR/*.war 


