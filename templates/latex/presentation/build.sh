#!/bin/bash

TEX_FILENAME=presentation

pdflatex -synctex=1 -interaction=nonstopmode $TEX_FILENAME.tex
pdflatex -synctex=1 -interaction=nonstopmode $TEX_FILENAME.tex

exit 0
