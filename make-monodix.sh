#!/bin/bash

# Heap space memory for JVM
defaultMinMem=1000
defaultMaxMem=4000
if [ "$CROSSDICS_PATH" = "" ];
then
	CROSSDICS_PATH="/usr/local/apertium-dixtools"
fi
library="$CROSSDICS_PATH/dist/apertium-dixtools.jar"
java_options="-Xms${defaultMinMem}m -Xmx${defaultMaxMem}m -jar ${library}"

# go!
time_start=$(date)

# speling -> dix
echo "- Converting speling to monodix"
java ${java_options} speling -standard de-vocab.speling tmp.dix &> speling.log

echo "- Chopping paradigms"
java ${java_options} equiv-paradigms tmp.dix apertium-de-en.de.dix &> equiv-pars.log

# dix -> bin
echo "- Compiling dictionaries"
lt-comp lr apertium-de-en.de.dix de-en.automorf.bin
lt-comp rl apertium-de-en.de.dix en-de.autogen.bin

# tests
echo "- Tests (should return zeros)"
cat de-vocab.speling | cut -d ";" -f 2 | sort | uniq | lt-proc de-en.automorf.bin | grep "\*" | wc
cat de-vocab.speling | cut -d ";" -f 2 | sort | uniq | lt-proc de-en.automorf.bin | grep -v "/" | wc

# done!
time_finish=$(date)

echo
echo "- Timing the whole thing:"
echo $time_start
echo $time_finish
