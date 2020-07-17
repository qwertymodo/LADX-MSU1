#!/usr/bin/env python3
import math
import sys
import random
from PIL import Image
from colormath.color_objects import sRGBColor, LabColor
from colormath.color_conversions import convert_color
from colormath.color_diff import delta_e_cie1976

def getpalette(image):
    palette = [(0,0,0)]
    w, h = image.size
    for y in range(h):
        for x in range(w):
            p = image.getpixel((x,y))
            c = (p[0], p[1], p[2])
            if not c in palette:
                palette.append(c)

    return palette

def run(image, output):
    img = Image.open(image, 'r')
    w, h = img.size

    masterPalette = img.getpalette()
    if masterPalette == None:
        masterPalette = getpalette(img)

    if not (0,0,0) in masterPalette:
        masterPalette.insert(0,(0,0,0))

    tw = int(w / 8)
    th = int(h / 8)
    tiles = []
    indexedTiles = []
    tilePalettes = []
    for ty in range(th):
        row = []
        for tx in range(tw):
            row.append(img.crop(((tx*8), (ty*8), (tx*8)+8, (ty*8)+8)))
        tiles.append(row)
        indexedTiles.append([[[0]*8]*8]*tw)
        tilePalettes.append([0]*tw)

    subPalettes = []
    if len(masterPalette) > 16:
        for i in range(3):
            subPalettes.append([(0,0,0)])
            for j in range(15):
                c = random.randrange(1,len(masterPalette))
                while masterPalette[c] in subPalettes[i]:
                    c = (c % (len(masterPalette) - 1)) + 1
                subPalettes[i].append(masterPalette[c])
    else:
        print(len(masterPalette), "colors")
        subPalettes.append(masterPalette)

    print(subPalettes)

    passcount = 1
    while True:
        changed = False
        changecount = 0

        for ty,row in enumerate(tiles):
            #print("Row", ty+1, "/", len(tiles), "( Pass", passcount, ")")
            for tx,tile in enumerate(row):
                tilepal = tile.getpalette()
                if tilepal == None:
                    tilepal = getpalette(tile)

                tilepal.remove((0,0,0))

                colormaps = []
                distances = []

                for p in subPalettes:
                    colormaps.append([])
                    distances.append([])

                w, h = tile.size
                for py in range(h):
                    for px in range(w):
                        pixc = tile.getpixel((px,py))
                        #lpixc = convert_color(sRGBColor(pixc[0],pixc[1],pixc[2],True), LabColor)
                        for pn,pal in enumerate(subPalettes):
                            bestcol = 0
                            bestdist = -1.0
                            for cn in range(1,len(pal)):
                                c = pal[cn]
                                #lc = convert_color(sRGBColor(c[0],c[1],c[2],True), LabColor)
                                #d = delta_e_cie1976(lpixc,lc)
                                d = math.sqrt((pixc[0]-c[0])**2)+((pixc[1]-c[1])**2)+((pixc[2]-c[2])**2)
                                if bestdist < 0 or d < bestdist:
                                    bestdist = d
                                    bestcol = cn
                            colormaps[pn].append(bestcol)
                            distances[pn].append(bestdist)

                bestpal = 0
                besttotaldist = sum(distances[0])
                for p in range(1,len(distances)):
                    d = sum(distances[p])
                    if d < besttotaldist:
                        bestpal = p
                        besttotaldist = d

                tilePalettes[ty][tx] = bestpal
                for py in range(h):
                    for px in range(w):
                        indexedTiles[ty][tx][py][px] = colormaps[bestpal][(py*w)+px]

        pmaps = []
        pmapcount = []
        for m in range(3):
            cmaps = []
            cmapcount = []
            for c in range(16):
                cmaps.append([])
                cmapcount.append([])
            pmaps.append(cmaps)
            pmapcount.append(cmapcount)

        for ty,row in enumerate(tiles):
            for tx,tile in enumerate(row):
                tilepal = tilePalettes[ty][tx]
                indexedTile = indexedTiles[ty][tx]
                w, h = tile.size
                for py in range(h):
                    for px in range(w):
                        pcol = tile.getpixel((px,py))
                        pcolid = indexedTile[py][px]
                        colmap = pmaps[tilepal][pcolid]
                        if not pcol in colmap:
                            colmap.append(pcol)
                            pmapcount[tilepal][pcolid].append(1)

                        else:
                            mapid = colmap.index(pcol)
                            pmapcount[tilepal][pcolid][mapid] += 1

        # For each palette:
        for pn,pal in enumerate(subPalettes):
            for cn in range(1,len(pal)):
                col = pal[cn]
                if len(pmaps[pn][cn]) > 0:
                    totalweight = sum(pmapcount[pn][cn])
                    currentweight = [0.0, 0.0, 0.0]
                    for wn,wcol in enumerate(pmaps[pn][cn]):
                        weight = pmapcount[pn][cn][wn] / totalweight
                        currentweight[0] += (wcol[0] * weight)
                        currentweight[1] += (wcol[1] * weight)
                        currentweight[2] += (wcol[2] * weight)

                    newcol = [int(currentweight[0]), int(currentweight[1]), int(currentweight[2])]

                    # If we want to restrict colors to the original palette
                    # find the closest match in the original palette, otherwise
                    # just replace the current color with the weighted average
                    if False:
                        #lweighted = convert_color(sRGBColor(newcol[0],newcol[1],newcol[2],True), LabColor)
                        bc = 0
                        bd = -1.0
                        newcol = [0, 0, 0]
                        for ci in range(1,len(masterPalette)):
                                c = masterPalette[ci]
                                #lc = convert_color(sRGBColor(c[0],c[1],c[2],True), LabColor)
                                #d = delta_e_cie1976(lweighted,lc)
                                d = abs((newcol[0]-c[0])**2)+((newcol[1]-c[1])**2)+((newcol[2]-c[2])**2)
                                if bd < 0 or d < bd:
                                    bc = ci
                                    bd = d
                                newcol[0] = masterPalette[ci][0]
                                newcol[1] = masterPalette[ci][2]
                                newcol[2] = masterPalette[ci][2]

                    if col[0] != newcol[0] or col[1] != newcol[1] or col[2] != newcol[2]:
                        nc = (newcol[0], newcol[1], newcol[2])
                        if not nc in subPalettes[pn]:
                            print(nc, subPalettes[pn])
                            print("Palette:", pn, "Index:", cn)
                            print("Old color:", col)
                            subPalettes[pn][cn] = nc
                            print("New color:", subPalettes[pn][cn])
                            changecount += 1
                            changed = True

                else:
                    c = random.randrange(1,len(masterPalette))
                    while not masterPalette[c] in pal:
                        c = (c % (len(masterPalette) - 1)) + 1
                    subPalettes[pn][cn] = masterPalette[c]

        # Repeat if any color has changed (other than unused colors that got randomized)
        if not changed:
            break

        else:
            print("Change count:", changecount)

        passcount += 1
    
    print("Indexed tiles:", len(indexedTiles))

    tilemap = []
    extendedmap = []
    mapindex = 1

    top = 5
    bottom = 22
    left = 6
    right = 25
    indexedImg = bytearray(32)
    for ty,row in enumerate(tiles):
        rowmid = (len(row) / 2) - 1
        leftedge = rowmid - 16
        rightedge = leftedge + 31
        left = 6 + leftedge
        right = 25 + leftedge

        for tx,tile in enumerate(row):
            # TODO : Put extended tiles in the extended tilemap instead of skipping them
            if (tx < leftedge) or (tx > rightedge):
                continue
            if (ty < top) or (ty > bottom) or (tx < left) or (tx > right):
                tilepal = tile.getpalette()
                if tilepal == None:
                    tilepal = getpalette(tile)

                pal = tilePalettes[ty][tx]
                indexedTile = bytearray(32)
                for y in range(8):
                    bitplane = bytearray(4)
                    for x in range(8):
                        #col = indexedTiles[ty][tx][y][x]
                        col = tiles[ty][tx].getpixel((x,y))
                        bc = 0
                        bd = -1.0
                        for ci in range(1,len(subPalettes[pal])):
                                c = subPalettes[pal][ci]
                                #lc = convert_color(sRGBColor(c[0],c[1],c[2],True), LabColor)
                                #d = delta_e_cie1976(lweighted,lc)
                                d = abs((col[0]-c[0])**2)+((col[1]-c[1])**2)+((col[2]-c[2])**2)
                                if bd < 0 or d < bd:
                                    bc = ci
                                    bd = d
                        for i in range(4):
                            bitplane[3 - i] |= (((bc >> (3 - i)) & 1) << (7 - x))

                    #print(bitplane)
                    indexedTile[(2*y)] = bitplane[0]
                    indexedTile[(2*y)+1] = bitplane[1]
                    indexedTile[(2*y)+16] = bitplane[2]
                    indexedTile[(2*y)+17] = bitplane[3]

                tilematch = -1
                for i in range(int(len(indexedImg)/32)):
                    found = True
                    for j in range(32):
                        if indexedImg[(32*i)+j] != indexedTile[j]:
                            found = False
                            break
                    if found:
                        tilematch = i
                        break

                if tilematch > 0:
                    tilemap.append(tilematch & 0xFF)
                    tilemap.append(((tilematch>>8) & 0x03) | (((pal+4)&0x07)<<2))

                else:
                    for i in range(32):
                        indexedImg.append(indexedTile[i])

                    #if tx < 32:
                    tilemap.append(mapindex & 0xFF)
                    tilemap.append(((mapindex>>8) & 0x03) | (((pal+4)&0x07)<<2))

                    #else:
                        #extendedmap.append(mapindex & 0xFF)
                        #extendedmap.append(((mapindex>>8) & 0x03) | (((pal+4)&0x07)<<2))

                    mapindex = mapindex + 1

            else:
                #if tx < 32:
                tilemap.append(0)
                tilemap.append(0)
                #else:
                    #extendedmap.append(0)
                    #extendedmap.append(0)

    out = open(output, 'w')

    #print(len(indexedImg))
    bank = 0
    for i,b in enumerate(indexedImg):
        if i % 0x1000 == 0:
            out.write("\nSGBFrameTiles")
            out.write(str(bank))
            out.write(":")
            bank = bank + 1
        if i % 8 == 0:
            out.write("\n    db $")
        else:
            out.write(", $")

        out.write(format(b, '02x'))

    while(len(tilemap) < 2048):
        tilemap.append(0)

    out.write("\n\nSGBFrameMetadata:\n// Tilemap")
    for i,b in enumerate(tilemap):
        if i % 8 == 0:
            out.write("\n    db $")
        else:
            out.write(", $")

        out.write(format(b, '02x'))

    if len(subPalettes) < 3:
        emptypal = [(0,0,0)] * 16
        while len(subPalettes) < 3:
            subPalettes.append(emptypal)

    for i,pal in enumerate(subPalettes):
        out.write("\n// Palette ")
        out.write(str(i+4))
        for col in pal:
            out.write("\nSGB.BGR555($")
            out.write(format(col[0], '02x'))
            out.write(format(col[1], '02x'))
            out.write(format(col[2], '02x'))
            out.write(")")

    while(len(extendedmap) < 2048):
        extendedmap.append(0)

    out.write("\n// Extended Tilemap")
    for i,b in enumerate(extendedmap):
        if i % 8 == 0:
            out.write("\n//    db $")
        else:
            out.write(", $")

        out.write(format(b, '02x'))


    out.close()


if __name__ == "__main__":
    if len(sys.argv) > 2:
        run(*sys.argv[1:])

    else:
        print("Invalid arguments")