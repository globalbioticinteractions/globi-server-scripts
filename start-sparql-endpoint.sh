#!/bin/bash
if [ -z "$GLOBI_HOME" ]; then 
	echo "please set GLOBI_HOME"
	exit 1
fi

FUSEKI_HOME="$GLOBI_HOME/eol-globi-rdf"
FUSEKI_VERSION="3.17.0"
FUSEKI_DIR="$FUSEKI_HOME/target/apache-jena-fuseki-${FUSEKI_VERSION}"
FUSEKI_DATA="$FUSEKI_HOME/target/apache-jena-fuseki-${FUSEKI_VERSION}/Data/interactions.nq.gz"

cd "$GLOBI_HOME"
echo fuseki rebuilding...
mvn clean install -pl eol-globi-rdf -am -Prdf --settings /etc/globi/.m2/settings.xml

# truncate interactions.nq.gz to 10M nquads for now.
cat ${FUSEKI_DATA} | gunzip | head -n10000000 | gzip > ${FUSEKI_DATA}.new
mv ${FUSEKI_DATA}.new ${FUSEKI_DATA}

echo fuseki starting...
cd $FUSEKI_DIR
java -Xmx18G -jar fuseki-server.jar --localhost --config="config.ttl" 
