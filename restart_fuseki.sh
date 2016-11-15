#!/bin/bash
source ~/.profile
if [ -z "$GLOBI_HOME" ]; then 
	echo "please set GLOBI_HOME"
	exit 1
fi

FUSEKI_HOME="$GLOBI_HOME/eol-globi-rdf"
FUSEKI_DIR="$FUSEKI_HOME/target"
DATA_DIR="$FUSEKI_DIR/blazegraph/data"
FUSEKI_PID="$FUSEKI_DIR/fuseki.pid"
PID=$(cat "$FUSEKI_PID" 2>/dev/null)
kill "$PID" 2>/dev/null

cd "$GLOBI_HOME"
echo rdf store rebuilding...
mvn clean install -pl eol-globi-rdf -Prdf

cd "$FUSEKI_DIR"
echo for now, only use first 100k quads
NQUAD_BLOB="$DATA_DIR/globi100k.nq.gz"
cat "$DATA_DIR/globi.nq.gz" | gunzip | head -n 100000 | gzip > $NQUAD_BLOB 

echo data import started...
java -Xmx6g -cp blazegraph-jar-2.1.4.jar com.bigdata.rdf.store.DataLoader -verbose -namespace globi blazegraph/conf/journal.properties $NQUAD_BLOB &> blazegraph-import.log &
echo data import done.

echo rdf store starting...
nohup java -server -Xmx8G -Djetty.host=127.0.0.1 -Djetty.port=3030 -jar blazegraph-jar-2.1.4.jar blazegraph/config/journal.properties &> $HOME/eol-globi-rdf.log &
echo $! > "$FUSEKI_PID"
echo rdf store started.
