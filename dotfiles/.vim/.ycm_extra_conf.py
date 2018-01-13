import os
import ycm_core

flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-DNDEBUG',
    '-D_GNU_SOURCE',
    '-std=gnu11',
    '-x',
    'c',
    '-I/usr/include'
]

SOURCE_EXTENSIONS = [ '.cpp', '.cc', '.c', ]

def FlagsForFile(filename, **kwargs):
    return {
        'flags': flags,
        'do_cache': True
    }
