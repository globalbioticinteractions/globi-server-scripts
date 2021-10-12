#!/bin/bash
if [ -z "$GLOBI_HOME" ]; then 
	echo "please set GLOBI_HOME"
	exit 1
fi

FUSEKI_HOME="$GLOBI_HOME/eol-globi-rdf"
FUSEKI_VERSION="3.17.0"
FUSEKI_DIR="$FUSEKI_HOME/target/apache-jena-fuseki-${FUSEKI_VERSION}"

cd "$GLOBI_HOME"
echo fuseki rebuilding...
mvn clean install -pl eol-globi-rdf -am -Prdf --settings /etc/globi/.m2/settings.xml

echo fuseki starting...
cd $FUSEKI_DIR
java -Xmx18G -jar fuseki-server.jar --localhost --config="config.ttl" 
