#!/bin/sh
# #############################################################
# script to disable UCD VCS rails.
# This REQUIRES unaltered/original UCD cfg file.
# 10/28/16 PGR -
# 11/10/16 PGR - unbind/bind UCD driver

ucd_retries=5
ucd=

# unbind ucd driver to permit i2cset
ucdpath="/sys/bus/i2c/drivers/ucd9000"
if [ -e $ucdpath ]
then
  ucd=`ls -1 $ucdpath | grep 64`
  if [ -n "$ucd" ]
  then
    echo $ucd > $ucdpath/unbind
  fi
fi

# Setup UCD module (in standby) to disable VCS rails from power-on:
i2cset -y 11 0x64 0xF7 0x00 i
i2cset -y 11 0x64 0xF8 0x15 0x6E 0x80 0x0A 0x00 0x00 0x10 0x00 0x00 0x00 \
	0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 i
i2cset -y 11 0x64 0xF7 0x01 i
i2cset -y 11 0x64 0xF8 0x15 0x16 0x80 0x14 0x00 0x00 0x20 0x00 0x00 0x00 \
	0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 i
i2cset -y 11 0x64 0xD2 0x09 0x3F 0xFF 0x2F 0x0A 0x00 0x06 0x00 0x00 0x02 i
i2cset -y 11 0x64 0x00 0x0E i
i2cset -y 11 0x64 0x02 0x1A i
i2cset -y 11 0x64 0x00 0x0F i
i2cset -y 11 0x64 0x02 0x1A i

# re-bind ucd driver only if we unbound it (i.e. ucd has been set with a value)
if [ -e $ucdpath -a -n "$ucd" ]; then
  j=0
  until [ $j -ge $ucd_retries ] || [ -e $ucdpath/$ucd ]; do
    j=$((j+1))
    echo $ucd > $ucdpath/bind || ret=$?
        if [ $j -gt 1 ]; then
          echo "rebinding UCD driver. Retry number $j"
          sleep 1
    fi
  done
  if [ ! -e $ucdpath/$ucd ]; then exit $ret; fi
fi

