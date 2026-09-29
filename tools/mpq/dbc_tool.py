#!/usr/bin/env python3
"""dbc_tool.py — EL PACTO: editor de Spell.dbc (formato WDBC 3.3.5)

Renombra hechizos y reescribe sus descripciones/tooltips (columnas enUS, texto
en español) para el parche de cliente. Las cadenas nuevas se AÑADEN al string
block (nunca se sobreescriben en sitio: las longitudes cambian) y se actualiza
el offset del registro + el tamaño del bloque en la cabecera.

Uso:
  python3 dbc_tool.py info Spell.dbc 78
  python3 dbc_tool.py rename Spell.dbc out.dbc renames.json
     renames.json: {"78": {"name": "Golpe del Alba", "rank": "Rango 1",
                            "desc": "Un golpe...", "tooltip": ""}, ...}

Columnas Spell.dbc 3.3.5 (verificadas empíricamente contra el DBC real):
  0 = ID · 136 = nombre enUS · 153 = rango enUS · 170 = descripción enUS ·
  187 = tooltip enUS. La descripción admite macros del cliente ($s1, $d, etc.).
"""
import json
import struct
import sys

COL_NAME, COL_RANK, COL_DESC, COL_TIP = 136, 153, 170, 187
HDR = struct.Struct('<4sIIII')


class Dbc:
    def __init__(self, path):
        self.raw = bytearray(open(path, 'rb').read())
        magic, self.recs, self.fields, self.recsize, self.strsize = HDR.unpack_from(self.raw, 0)
        assert magic == b'WDBC', 'no es un WDBC'
        assert self.recsize == self.fields * 4
        self.body = HDR.size
        self.strblock = self.body + self.recs * self.recsize
        self.index = {}
        for i in range(self.recs):
            off = self.body + i * self.recsize
            self.index[struct.unpack_from('<I', self.raw, off)[0]] = off

    def get(self, spell_id, col):
        off = self.index[spell_id]
        sofs = struct.unpack_from('<I', self.raw, off + col * 4)[0]
        if sofs == 0:
            return ''
        end = self.raw.index(b'\0', self.strblock + sofs)
        return self.raw[self.strblock + sofs:end].decode('utf-8', 'replace')

    def set_str(self, spell_id, col, text):
        # añade la cadena al final del bloque y apunta el registro ahí
        new_ofs = self.strsize
        self.raw += text.encode('utf-8') + b'\0'
        self.strsize = len(self.raw) - self.strblock
        struct.pack_into('<I', self.raw, self.index[spell_id] + col * 4, new_ofs)

    def save(self, path):
        HDR.pack_into(self.raw, 0, b'WDBC', self.recs, self.fields, self.recsize, self.strsize)
        open(path, 'wb').write(self.raw)


def main():
    cmd = sys.argv[1]
    dbc = Dbc(sys.argv[2])
    if cmd == 'info':
        sid = int(sys.argv[3])
        print(f"#{sid}: name={dbc.get(sid, COL_NAME)!r} rank={dbc.get(sid, COL_RANK)!r}")
        print(f"  desc={dbc.get(sid, COL_DESC)!r}")
        print(f"  tip ={dbc.get(sid, COL_TIP)!r}")
    elif cmd == 'rename':
        out, spec = sys.argv[3], json.load(open(sys.argv[4]))
        for sid, ch in spec.items():
            sid = int(sid)
            if 'name' in ch: dbc.set_str(sid, COL_NAME, ch['name'])
            if 'rank' in ch: dbc.set_str(sid, COL_RANK, ch['rank'])
            if 'desc' in ch: dbc.set_str(sid, COL_DESC, ch['desc'])
            if 'tooltip' in ch: dbc.set_str(sid, COL_TIP, ch['tooltip'])
            print(f"#{sid} -> {ch.get('name', '(sin cambio de nombre)')}")
        dbc.save(out)
        print(f"guardado: {out} ({len(spec)} hechizos)")
    else:
        sys.exit('comando: info | rename')


if __name__ == '__main__':
    main()
