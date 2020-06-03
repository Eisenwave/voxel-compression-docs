#!/bin/bash

for f in *.dot; do
    out="../img/graph/${f%.dot}.svg"
    dot "$f" -o "$out" -Tsvg
done
