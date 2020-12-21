#!/usr/bin/python
import sys
from collections import defaultdict

def conv(border):
    return sum([(1<<i) if b=='#' else 0 for i,b in enumerate(border)])

def make_tile(lines):
    l,r = [],[]
    for line in lines:
        l.append(line[0])
        r.append(line[-1])
    borders = [lines[0], ''.join(r), lines[-1], ''.join(l)]
    tile = zip(map(conv, borders), map(conv, map(reversed, borders)))
    tile.append(lines)

    return tile

def read_tiles():
    tiles = {}
    no = 0
    lines = []
    for line in sys.stdin:
        line = line.rstrip()
        if line == '':
            tiles[no] = make_tile(lines)
            lines = []
        elif line[-1] == ':':
            no = int(line[5:-1])
        else:
            lines.append(line)
    tiles[no] = make_tile(lines)

    return tiles

def invert(tiles):
    inverted = defaultdict(list)
    for no, tile in tiles.iteritems():
        for i,ii in tile[:4]:
            inverted[i].append(no)
            inverted[ii].append(no)
    return inverted

def find_corners(inverted):
    singles = defaultdict(list)
    for edge, nos in inverted.iteritems():
        if len(nos) > 2:
            raise ValueError("Not unique border", (edge, nos))
        if len(nos) == 1:
            singles[nos[0]].append(edge)
    return [p for p in singles.iteritems() if len(p[1]) == 4]

def find_other_edge(edge, dir, tiles, inverted):
    nos = [no for no in inverted[edge] if no in tiles]
    if not nos:
        return None
    if len(nos) > 1:
        raise ValueError("Got more for tiles for edge", (edge, nos))
    no = nos[0]
    tile = tiles[no]
    ((ei, p),) = [(idx, p) for idx, conv in enumerate(tile[:4]) for p in (0,1) if conv[p] == edge]
    (idx, conv), = [(idx, conv) for idx, conv in enumerate(tile[:4]) if conv[p] != edge and len(inverted[conv[p]]) == 1 and abs(idx-ei) != 2]
    return conv[p] if ((idx-ei) % 4) == dir else conv[1-p]


def find_next(left, top, tiles, inverted):
    if left is None:
        if not [no for no in inverted[top] if no in tiles]:
            return None
        left = find_other_edge(top, 3, tiles, inverted)
        if left is None:
            raise ValueError("Can't find other edge for", top)
    elif top is None:
        if not [no for no in inverted[left] if no in tiles]:
            return None
        top = find_other_edge(left, 1, tiles, inverted)
        if top is None:
            raise ValueError("Can't find other edge for", left)
    nos = [no for no in inverted[left] if no in tiles]
    if not nos:
        return None
    if len(nos) > 1:
        raise ValueError("More than one candidate for next tile", nos)
    no = nos[0]
    matched = [idx for idx, (i,ii) in enumerate(tiles[no][:4]) if i == left or ii == left or i == top or ii == top]
    if len(matched) != 2:
        raise ValueError("Can't find required edges in candidate", matched)
    if abs(matched[0] - matched[1]) == 2:
        raise ValueError("Found edges is opposite to each other", matched)
    return (no, left, top)

def rotate(tile, cw):
    if (cw % 4) == 0:
        return tile

    nt = [tile[(idx-cw) % 4] for idx in range(4)]
    m = len(tile[4]) - 1
    def nx(x, y): return m - x if cw == 2 else (y if cw == 1 else m - y)
    def ny(x, y): return m - y if cw == 2 else (x if cw == 3 else m - x)
    lines = [[tile[4][ny(x,y)][nx(x,y)] for x,_ in enumerate(line)] for y, line in enumerate(tile[4])]
    nt.append([''.join(a) for a in lines])
    return nt

def flip(tile):
    nt = [tile[2], (tile[1][1], tile[1][0]), tile[0], (tile[3][1], tile[3][0]), list(reversed(tile[4]))]
    return nt

def flip_dia(tile):
    lines = [[tile[4][x][y] for x,_ in enumerate(line)] for y, line in enumerate(tile[4])]
    nt = [tile[3], tile[2], tile[1], tile[0]]
    nt.append([''.join(a) for a in lines])
    return nt

def transform(no, left, top, tiles):
    tile = tiles[no]

    idx, = [idx for idx, (i,ii) in enumerate(tile[:4]) if i == left or ii == left]
    cw = 3 - idx
    tile = rotate(tile, cw)
    if left != tile[3][0]:
        tile = flip(tile)
    if tile[0][0] == top:
        pass
    elif tile[0][1] == top:
        tile = flip_dia(flip(rotate(tile,3)))
    elif tile[2][0] == top:
        tile = flip_dia(rotate(tile,1))
    elif tile[2][1] == top:
        tile = rotate(flip(rotate(tile, 1)), 1)
    else:
        raise ValueError("Bad tile for rot/flip", (left, top, tile[:4]))
    return tile

def combine(corners, tiles, inverted):
    image = []
    row = []
    no, edges = corners[0]
    convs = [conv for conv in tiles[no][:4] if conv[0] in edges]
    left, top = convs[0][0], None
    while len(tiles):
        nx = find_next(left, top, tiles, inverted)
        if nx is None:
            image.append(row)
            row = []
            nx = find_next(None, image[-1][0][2][0], tiles, inverted)
            if nx is None:
                raise ValueError("Can't find next tile", (None, image[-1][0][2][0]))
        no, left, top = nx
        tile = transform(no, left, top, tiles)
        del tiles[no]
        row.append(tile)
        if not tiles:
            break
        left, top = tile[1][0], image[-1][len(row)][2][0] if (len(image) and len(image[-1]) > len(row)) else None
    image.append(row)
    return image

def stitch(combined):
    image = []
    for row in combined:
        image.extend([''.join([t[4][idx][1:-1] for t in row]) for idx in range(1, len(row[0][4])-1)])
    return image

def get_monster(img):
    lines = img.split("\n")[1:-1]
    coords = [(x,y) for y, line in enumerate(lines) for x in range(len(line)) if lines[y][x] == '#']
    return (coords, len(lines[0]), len(lines))

def find_monsters(img, monster):
    coords, width, height = monster
    monster_points = []
    for y in range(len(img) - height):
        for x in range(len(img[y]) - width):
            pts = []
            for dx, dy in coords:
                if img[y+dy][x+dx] == '#':
                    pts.append((x+dx, y+dy))
                else:
                    break
            if len(pts) == len(coords):
                monster_points.extend(pts)

    if not monster_points:
        return None

    roughness = 0
    for y in range(len(img)):
        for x in range(len(img[y])):
            if img[y][x] == '#' and (x,y) not in monster_points:
                roughness += 1
    return roughness

tiles = read_tiles()
inverted = invert(tiles)
corners = find_corners(inverted)
print reduce(lambda a,b:a*b[0], corners, 1)

# Part 2
monster_img = """
                  #
#    ##    ##    ###
 #  #  #  #  #  #
"""
monster = get_monster(monster_img)
combined = combine(corners, tiles, inverted)

orig = stitch(combined)

for f in (False, True):
    for cw in range(4):
        image = orig
        if f:
            image = flip(combined[0][0][:4] + [image])[4]
        image = rotate(combined[0][0][:4] + [image], cw)[4]
        monsters = find_monsters(image, monster)
        if monsters is not None:
            print monsters
