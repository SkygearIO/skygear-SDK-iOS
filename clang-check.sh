#!/bin/sh
find ./Pod ./Example/Tests -name "*.[hm]" -exec clang-format -style=file -output-replacements-xml "{}" \; | grep "<replacement " >/dev/null
if [ $? -ne 1 ]
then 
    echo "Commit did not match clang-format"
    exit 1;
fi
