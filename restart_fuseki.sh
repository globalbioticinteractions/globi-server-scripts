source ~/.bashrc
GLOBI_HOME="/var/cache/globi/ramdisk/eol-globi-data"
FUSEKI_HOME="$GLOBI_HOME/eol-globi-rdf"
FUSEKI_DIR="$FUSEKI_HOME/target/jena-fuseki-0.2.7"
FUSEKI_PID="$FUSEKI_DIR/fuseki.pid"
PID=$(cat "$FUSEKI_PID" 2>/dev/null)
kill "$PID" 2>/dev/null

cd "$GLOBI_HOME"
echo fuseki rebuilding...
mvn clean install -pl eol-globi-rdf -Prdf

echo fuseki starting...
nohup java -Xmx6G -jar $FUSEKI_DIR/fuseki-server.jar --config="$FUSEKI_DIR/config.ttl" --pages="$FUSEKI_DIR/pages" &> /home/jhpoelen/eol-globi-rdf.log &
echo $! > "$FUSEKI_PID"
echo fuseki started.


