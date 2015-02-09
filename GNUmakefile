OCAMLFIND ?= ocamlfind
OCAMLC_FLAGS = -package xml-light -w +A-44
OCAMLC = $(OCAMLFIND) ocamlc $(OCAMLC_FLAGS)
OCAMLOPT = $(OCAMLFIND) ocamlopt $(OCAMLC_FLAGS)

.PHONY: all clean doc install lib top uninstall

all: lib

clean:
	$(RM) tcx.a tcx.cma tcx.cmi tcx.cmo tcx.cmx tcx.cmxa tcx.o

doc:

install: META tcx.a tcx.cma tcx.cmi tcx.cmxa
	$(OCAMLFIND) install tcx $^

lib: tcx.cma tcx.cmxa

top: lib
	utop -require xml-light

uninstall:
	$(OCAMLFIND) remove tcx

tcx.a: tcx.cmxa

tcx.cma: tcx.ml tcx.cmi
	$(OCAMLC) -a $< -o $@

tcx.cmxa: tcx.ml tcx.cmi
	$(OCAMLOPT) -a $< -o $@

tcx.cmi: tcx.mli
	$(OCAMLC) -c $< -o $@
