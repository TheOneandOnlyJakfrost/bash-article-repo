#!/bin/bash

# Adapted from - https://github.com/tdg5/blog/blob/master/_includes/scripts/dd_obs_test.sh

# Since we're dealing with dd, abort if any errors occur
set -eou pipefail

usage(){
	echo "Usage: $0 input_file output_device"
	exit 1
}

if [ "$#" -ne 2 ]; then
	usage
fi

if [ ! -f "$1" ]; then
	echo "$1 does not exist"
	exit 1
fi

if [ ! -b "$2" ]; then
	echo "$2 is not a block device"
	exit 1
fi

INPUT_FILE="$1"
INPUT_FILE_SIZE=$(stat --printf="%s" "$INPUT_FILE")
OUTPUT_DEVICE="$2"
# Header
PRINTF_FORMAT="%10s : %8s : %s\n"
printf "%10s : %s\n" "file size" "$INPUT_FILE_SIZE"
printf "$PRINTF_FORMAT" 'block size' 'count' 'transfer rate'

# Block sizes of 512b 1K 2K 4K 8K 16K 32K 64K 128K 256K 512K 1M 2M 4M 8M 16M 32M 64M
for BLOCK_SIZE in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864
do
  # Calculate number of segments required to copy
  COUNT=$(($INPUT_FILE_SIZE / $BLOCK_SIZE))

  if [ $COUNT -le 0 ]; then
    echo "Block size of $BLOCK_SIZE estimated to require $COUNT blocks, aborting further tests."
    break
  fi

	# dd the input file to the device
  DD_RESULT=$(dd if="$INPUT_FILE" of="$OUTPUT_DEVICE" bs=$BLOCK_SIZE count=$COUNT 2>&1 1>/dev/null)

  # Extract the transfer rate from dd's STDERR output
  TRANSFER_RATE=$(echo $DD_RESULT | \grep --only-matching -E '[0-9.]+ ([MGk]?B|bytes)/s(ec)?')

  # Output the result
  printf "$PRINTF_FORMAT" "$BLOCK_SIZE" "$COUNT" "$TRANSFER_RATE"
done

