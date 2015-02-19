# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
export JAVA_HOME=/usr/lib/jvm/java/
export M2_HOME=/usr/local/apache-maven/apache-maven-3.0.4 
export M2=$M2_HOME/bin 
export PATH=$M2:$PATH 
export RAMDISK=/var/cache/globi/ramdisk/eol-globi-data
