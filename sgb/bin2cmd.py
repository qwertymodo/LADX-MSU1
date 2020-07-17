#!/usr/bin/env python3
import sys
blocksize = 11

def run (input, output, address, reverse=False):
    infile = open(input, 'rb')
    outfile = open(output, 'wb')
    dest = int(address, 16)

    blocks = []

    while True:
        block = infile.read(blocksize)
        blocklen = len(block)
        if blocklen > 0:
            if reverse:
                blocks.append(block)
            else:
                outfile.write(bytes([0x79, (dest & 0xFF), ((dest >> 8) & 0xFF), ((dest >> 16) & 0xFF), blocklen]))
                outfile.write(block)
        if blocklen < blocksize:
            if blocklen and not reverse:
                outfile.write(bytes(blocksize-blocklen))
            break
        
        dest += blocklen

    if reverse:
        for block in reversed(blocks):
            blocklen = len(block)
            dest -= blocksize
            
            outfile.write(bytes([0x79, (dest & 0xFF), ((dest >> 8) & 0xFF), ((dest >> 16) & 0xFF), blocklen]))
            outfile.write(block)

            if blocklen < blocksize:
                outfile.write(bytes(blocksize-blocklen))


if __name__ == "__main__":
    if len(sys.argv) > 2:
        run(*sys.argv[1:])
    
    else:
        print("Invalid arguments")
