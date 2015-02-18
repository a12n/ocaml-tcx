OCAMLFIND ?= ocamlfind
OCAMLC_FLAGS = -package xml-light -w +A-44
OCAMLC = ${OCAMLFIND} ocamlc ${OCAMLC_FLAGS}
OCAMLOPT = ${OCAMLFIND} ocamlopt ${OCAMLC_FLAGS}
INSTALL_FILES = META list_ext.cmi list_ext.mli tcx.cmi tcx.mli \
			tcx.cma tcx.a tcx.cmxa
BUILD_FILES = list_ext.cmi list_ext.cmo list_ext.cmx list_ext.o \
			tcx.a tcx.cma tcx.cmi tcx.cmo tcx.cmx tcx.cmxa tcx.o

.PHONY: all clean doc install lib top uninstall
.SUFFIXES: .cmi .cmo .cmx .ml .mli


all: lib

clean:
	rm -f ${BUILD_FILES}

doc:

install: ${INSTALL_FILES}
	${OCAMLFIND} install tcx ${INSTALL_FILES}

lib: tcx.cma tcx.cmxa

top: lib
	utop -require xml-light

uninstall:
	${OCAMLFIND} remove tcx


tcx.cma: list_ext.cmo tcx.cmo
	${OCAMLC} -o $@ -a list_ext.cmo tcx.cmo

tcx.cmxa: list_ext.cmx tcx.cmx
	${OCAMLOPT} -o $@ -a list_ext.cmx tcx.cmx

list_ext.cmo: list_ext.cmi

list_ext.cmx: list_ext.cmi

tcx.cmi: list_ext.cmi

tcx.cmo: list_ext.cmi tcx.cmi

tcx.cmx: list_ext.cmx tcx.cmi


.ml.cmo:
	${OCAMLC} -c $<

.ml.cmx:
	${OCAMLOPT} -c $<

.mli.cmi:
	${OCAMLC} $<
