#!/bin/bash

TEX_FILENAME=academic

pdflatex -synctex=1 -interaction=nonstopmode $TEX_FILENAME.tex
makeglossaries $TEX_FILENAME
biber $TEX_FILENAME
pdflatex -synctex=1 -interaction=nonstopmode $TEX_FILENAME.tex
pdflatex -synctex=1 -interaction=nonstopmode $TEX_FILENAME.tex

exit 0