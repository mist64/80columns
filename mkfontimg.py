#!/usr/bin/python
import sys
import struct
import PIL.Image as Image

text = """\
10 poke53280,0:poke53281,1
20 print"\xd0\xd3";
30 fory=0to7
40 forx=0to15
50 poke49152+111+x+80*y,x+16*y
60 next
70 next
80 list"""

lowercase = False
if sys.argv[1] == '-l':
    lowercase = True
    del sys.argv[1]

def toscreencode(ch):
    cc = ord(ch)
    if '`' <= ch <= '~': return cc - 96
    return cc

charset = open(sys.argv[1], "rb").read()


FG = 0xFFDE7886
BG = 0xFFAA3A48

def putcat(img, r, c, code, lowercase):
    inverse = code & 128
    code = code % 128
    idx = code*8
    for y in range(8):
        data = charset[idx+y+lowercase*1024]
        if not inverse: data = ~data
        for x in range(4):
            if ~data & (1<<(3-x)):
                img.putpixel((8+4*c+x,8+8*r+y), FG)

BG_buf = struct.pack('<I', BG)
img = Image.frombytes('RGBA', (16+188,16+64), BG_buf * (16+188)*(16+64))

for i in range(8):
    for x in range(img.width):
        img.putpixel((x, i), FG)
        img.putpixel((x, img.height-i-1), FG)
    for y in range(img.height):
        img.putpixel((i, y), FG)
        img.putpixel((img.width-i-1, y), FG)
r=c=0
for ch in text:
    if ch == '\n':
        r = r + 1
        c = 0
        continue 
    putcat(img, r, c, toscreencode(ch), lowercase)
    c = c + 1
    if c == 80:
        r = r + 1
        c = 0
for r in range(8):
    for c in range(16):
        putcat(img, r, c+31, r*16+c, lowercase)

img = img.resize((img.size[0]*3, img.size[1]*3))
img.save(sys.argv[2])
