OCAMLFIND ?= ocamlfind
OCAMLC_FLAGS = -package xml-light
OCAMLC = $(OCAMLFIND) ocamlc $(OCAMLC_FLAGS)
OCAMLOPT = $(OCAMLFIND) ocamlopt $(OCAMLC_FLAGS)

.PHONY: all clean doc lib top

all: lib

clean:
	$(RM) tcx.a tcx.cma tcx.cmi tcx.cmo tcx.cmx tcx.cmxa tcx.o

doc:

lib: tcx.cma tcx.cmxa

top: lib
	utop -require xml-light

tcx.cma: tcx.ml tcx.cmi
	$(OCAMLC) -a $< -o $@

tcx.cmxa: tcx.ml tcx.cmi
	$(OCAMLOPT) -a $< -o $@

tcx.cmi: tcx.mli
	$(OCAMLC) -c $< -o $@
