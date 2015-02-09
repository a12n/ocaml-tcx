OCAMLFIND ?= ocamlfind
OCAMLC_FLAGS = -package xml-light -w +A-44
OCAMLC = ${OCAMLFIND} ocamlc ${OCAMLC_FLAGS}
OCAMLOPT = ${OCAMLFIND} ocamlopt ${OCAMLC_FLAGS}
INSTALL_FILES = META tcx.a tcx.cma tcx.cmi tcx.cmxa

.PHONY: all clean doc install lib top uninstall

all: lib

clean:
	rm -f tcx.a tcx.cma tcx.cmi tcx.cmo tcx.cmx tcx.cmxa tcx.o

doc:

install: ${INSTALL_FILES}
	${OCAMLFIND} install tcx ${INSTALL_FILES}

lib: tcx.cma tcx.cmxa

top: lib
	utop -require xml-light

uninstall:
	${OCAMLFIND} remove tcx

tcx.a: tcx.cmxa

tcx.cma: tcx.ml tcx.cmi
	${OCAMLC} -a tcx.ml -o $@

tcx.cmxa: tcx.ml tcx.cmi
	${OCAMLOPT} -a tcx.ml -o $@

tcx.cmi: tcx.mli
	${OCAMLC} -c tcx.mli -o $@
