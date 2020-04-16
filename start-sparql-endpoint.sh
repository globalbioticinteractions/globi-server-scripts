#!/bin/bash
if [ -z "$GLOBI_HOME" ]; then 
	echo "please set GLOBI_HOME"
	exit 1
fi

FUSEKI_HOME="$GLOBI_HOME/eol-globi-rdf"
FUSEKI_DIR="$FUSEKI_HOME/target/apache-jena-fuseki-2.4.0"

cd "$GLOBI_HOME"
echo fuseki rebuilding...
mvn clean install -pl eol-globi-rdf -am -Prdf

echo fuseki starting...
cd $FUSEKI_DIR
java -Xmx12G -jar fuseki-server.jar --localhost --config="config.ttl" &> $FUSEKI_DIR/eol-globi-rdf.log &
