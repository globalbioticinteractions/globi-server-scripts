#!/bin/bash
source ~/.profile
if [ -z "$GLOBI_HOME" ]; then 
	echo "please set GLOBI_HOME"
	exit 1
fi

FUSEKI_HOME="$GLOBI_HOME/eol-globi-rdf"
FUSEKI_DIR="$FUSEKI_HOME/target/apache-jena-fuseki-2.4.0"
FUSEKI_PID="$FUSEKI_DIR/fuseki.pid"
PID=$(cat "$FUSEKI_PID" 2>/dev/null)
kill "$PID" 2>/dev/null

cd "$GLOBI_HOME"
echo fuseki rebuilding...
mvn clean install -pl eol-globi-rdf -Prdf

echo fuseki starting...
cd $FUSEKI_DIR
nohup java -Xmx12G -jar fuseki-server.jar --localhost --config="config.ttl" &> $FUSEKI_DIR/eol-globi-rdf.log &
echo $! > "$FUSEKI_PID"
echo fuseki started.
