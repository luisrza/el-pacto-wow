#!/usr/bin/env python3
"""mpq_pack.py — EL PACTO: empaqueta archivos en un parche MPQ (StormLib vía ctypes)

Uso:
  python3 mpq_pack.py crear patch-4.MPQ "DBFilesClient\\Spell.dbc=Spell-pacto.dbc" [más...]
  python3 mpq_pack.py verificar patch-4.MPQ "DBFilesClient\\Spell.dbc" original.dbc
"""
import ctypes
import os
import sys

storm = ctypes.CDLL('/opt/homebrew/lib/libstorm.dylib')

MPQ_CREATE_LISTFILE   = 0x00100000
MPQ_CREATE_ARCHIVE_V1 = 0x00000000
MPQ_FILE_COMPRESS     = 0x00000200
MPQ_FILE_REPLACE      = 0x80000000
MPQ_COMPRESSION_ZLIB  = 0x02

storm.SFileCreateArchive.argtypes = [ctypes.c_char_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.POINTER(ctypes.c_void_p)]
storm.SFileAddFileEx.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_uint32]
storm.SFileOpenArchive.argtypes = [ctypes.c_char_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.POINTER(ctypes.c_void_p)]
storm.SFileOpenFileEx.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_uint32, ctypes.POINTER(ctypes.c_void_p)]
storm.SFileReadFile.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint32, ctypes.POINTER(ctypes.c_uint32), ctypes.c_void_p]
storm.SFileGetFileSize.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_uint32)]


def crear(mpq_path, pares):
    if os.path.exists(mpq_path):
        os.remove(mpq_path)
    h = ctypes.c_void_p()
    ok = storm.SFileCreateArchive(mpq_path.encode(), MPQ_CREATE_ARCHIVE_V1 | MPQ_CREATE_LISTFILE,
                                  max(8, len(pares) * 2), ctypes.byref(h))
    if not ok:
        sys.exit(f"SFileCreateArchive falló (errno {ctypes.get_errno()})")
    for par in pares:
        interno, fuente = par.split('=', 1)
        ok = storm.SFileAddFileEx(h, fuente.encode(), interno.encode(),
                                  MPQ_FILE_COMPRESS | MPQ_FILE_REPLACE,
                                  MPQ_COMPRESSION_ZLIB, MPQ_COMPRESSION_ZLIB)
        print(("+ " if ok else "FALLO ") + interno + " <- " + fuente)
        if not ok:
            sys.exit(1)
    storm.SFileCloseArchive(h)
    print(f"creado: {mpq_path} ({os.path.getsize(mpq_path)} bytes)")


def verificar(mpq_path, interno, contra):
    h = ctypes.c_void_p()
    if not storm.SFileOpenArchive(mpq_path.encode(), 0, 0, ctypes.byref(h)):
        sys.exit("no pude abrir el MPQ")
    f = ctypes.c_void_p()
    if not storm.SFileOpenFileEx(h, interno.encode(), 0, ctypes.byref(f)):
        sys.exit("archivo interno no encontrado")
    high = ctypes.c_uint32(0)
    size = storm.SFileGetFileSize(f, ctypes.byref(high))
    buf = ctypes.create_string_buffer(size)
    got = ctypes.c_uint32(0)
    storm.SFileReadFile(f, buf, size, ctypes.byref(got), None)
    storm.SFileCloseFile(f)
    storm.SFileCloseArchive(h)
    original = open(contra, 'rb').read()
    print(f"interno: {size} bytes · fuente: {len(original)} bytes · "
          + ("IDÉNTICOS ✓" if buf.raw[:got.value] == original else "DIFIEREN ✗"))


if __name__ == '__main__':
    if sys.argv[1] == 'crear':
        crear(sys.argv[2], sys.argv[3:])
    elif sys.argv[1] == 'verificar':
        verificar(sys.argv[2], sys.argv[3], sys.argv[4])
