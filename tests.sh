#!/bin/bash
docker exec z80 bash -c "cd ~/RC2014-nascom; make"
(
echo hload
cat tests.hex
echo "?usr(0)"
) | tr "\n" "\r" | nc 192.168.0.46 23