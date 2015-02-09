OCAMLFIND ?= ocamlfind
OCAMLC_FLAGS = -package xml-light
OCAMLC = $(OCAMLFIND) ocamlc $(OCAMLC_FLAGS)
OCAMLOPT = $(OCAMLFIND) ocamlopt $(OCAMLC_FLAGS)

.PHONY: all clean doc lib top

all: lib

clean:
	$(RM) tcx.cma tcx.cmi tcx.cmo

doc:

lib: tcx.cma

top: lib
	utop -I _build/src

tcx.cma: tcx.ml tcx.cmi
	$(OCAMLC) -a $< -o $@

tcx.cmi: tcx.mli
	$(OCAMLC) -c $< -o $@
