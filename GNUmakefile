OCAMLBUILD_FLAGS ?=
OCAMLBUILD_FLAGS += -cflags -w,+A-44
OCAMLBUILD_FLAGS += -docflags -charset,utf-8,-stars
OCAMLBUILD_FLAGS += -use-ocamlfind

.PHONY: all clean doc lib top

all: lib

clean:
	ocamlbuild $(OCAMLBUILD_FLAGS) -clean

doc:
	ocamlbuild $(OCAMLBUILD_FLAGS) tcx.docdir/index.html

lib:
	ocamlbuild $(OCAMLBUILD_FLAGS) tcx.cma
	ocamlbuild $(OCAMLBUILD_FLAGS) tcx.cmxa

top: lib
	utop -I _build/src
