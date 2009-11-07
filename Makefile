# auto generated - do not edit

default: all

all:\
UNIT_TESTS/data.ali UNIT_TESTS/data.o UNIT_TESTS/getline.ali \
UNIT_TESTS/getline.o UNIT_TESTS/init UNIT_TESTS/init.ali UNIT_TESTS/init.o \
UNIT_TESTS/mapper.ali UNIT_TESTS/mapper.o UNIT_TESTS/mapper_main \
UNIT_TESTS/mapper_main.ali UNIT_TESTS/mapper_main.o UNIT_TESTS/test.a \
UNIT_TESTS/test.ali UNIT_TESTS/test.o spatial_hash.ali spatial_hash.o

# Mkf-test
tests:
	(cd UNIT_TESTS && make)
tests_clean:
	(cd UNIT_TESTS && make clean)

UNIT_TESTS/data.ads:\
spatial_hash.ali

UNIT_TESTS/data.o UNIT_TESTS/data.ali:\
ada-compile UNIT_TESTS/data.adb UNIT_TESTS/data.ads
	./ada-compile UNIT_TESTS/data.adb

UNIT_TESTS/getline.o UNIT_TESTS/getline.ali:\
ada-compile UNIT_TESTS/getline.adb UNIT_TESTS/getline.ads
	./ada-compile UNIT_TESTS/getline.adb

UNIT_TESTS/init:\
ada-bind ada-link UNIT_TESTS/init.ald UNIT_TESTS/init.ali UNIT_TESTS/data.ali \
UNIT_TESTS/test.ali spatial_hash.ali UNIT_TESTS/test.a
	./ada-bind UNIT_TESTS/init.ali
	./ada-link UNIT_TESTS/init UNIT_TESTS/init.ali UNIT_TESTS/test.a

UNIT_TESTS/init.o UNIT_TESTS/init.ali:\
ada-compile UNIT_TESTS/init.adb UNIT_TESTS/data.ali UNIT_TESTS/test.ali
	./ada-compile UNIT_TESTS/init.adb

UNIT_TESTS/mapper.o UNIT_TESTS/mapper.ali:\
ada-compile UNIT_TESTS/mapper.adb UNIT_TESTS/mapper.ads UNIT_TESTS/getline.ali \
spatial_hash.ali
	./ada-compile UNIT_TESTS/mapper.adb

UNIT_TESTS/mapper_main:\
ada-bind ada-link UNIT_TESTS/mapper_main.ald UNIT_TESTS/mapper_main.ali \
UNIT_TESTS/mapper.ali spatial_hash.ali
	./ada-bind UNIT_TESTS/mapper_main.ali
	./ada-link UNIT_TESTS/mapper_main UNIT_TESTS/mapper_main.ali

UNIT_TESTS/mapper_main.o UNIT_TESTS/mapper_main.ali:\
ada-compile UNIT_TESTS/mapper_main.adb UNIT_TESTS/mapper.ali
	./ada-compile UNIT_TESTS/mapper_main.adb

UNIT_TESTS/test.a:\
cc-slib UNIT_TESTS/test.sld UNIT_TESTS/test.o
	./cc-slib UNIT_TESTS/test UNIT_TESTS/test.o

UNIT_TESTS/test.o UNIT_TESTS/test.ali:\
ada-compile UNIT_TESTS/test.adb UNIT_TESTS/test.ads
	./ada-compile UNIT_TESTS/test.adb

ada-bind:\
conf-adabind conf-systype conf-adatype conf-adafflist flags-cwd

ada-compile:\
conf-adacomp conf-adatype conf-systype conf-adacflags conf-adafflist flags-cwd

ada-link:\
conf-adalink conf-adatype conf-systype

ada-srcmap:\
conf-adacomp conf-adatype conf-systype

ada-srcmap-all:\
ada-srcmap conf-adacomp conf-adatype conf-systype

cc-compile:\
conf-cc conf-cctype conf-systype

cc-link:\
conf-ld conf-ldtype conf-systype

cc-slib:\
conf-systype

conf-adatype:\
mk-adatype
	./mk-adatype > conf-adatype.tmp && mv conf-adatype.tmp conf-adatype

conf-cctype:\
conf-cc mk-cctype
	./mk-cctype > conf-cctype.tmp && mv conf-cctype.tmp conf-cctype

conf-ldtype:\
conf-ld mk-ldtype
	./mk-ldtype > conf-ldtype.tmp && mv conf-ldtype.tmp conf-ldtype

conf-systype:\
mk-systype
	./mk-systype > conf-systype.tmp && mv conf-systype.tmp conf-systype

mk-adatype:\
conf-adacomp conf-systype

mk-cctype:\
conf-cc conf-systype

mk-ctxt:\
mk-mk-ctxt
	./mk-mk-ctxt

mk-ldtype:\
conf-ld conf-systype conf-cctype

mk-mk-ctxt:\
conf-cc conf-ld

mk-systype:\
conf-cc conf-ld

spatial_hash.o spatial_hash.ali:\
ada-compile spatial_hash.adb spatial_hash.ads
	./ada-compile spatial_hash.adb

clean-all: tests_clean obj_clean ext_clean
clean: obj_clean
obj_clean:
	rm -f UNIT_TESTS/data.ali UNIT_TESTS/data.o UNIT_TESTS/getline.ali \
	UNIT_TESTS/getline.o UNIT_TESTS/init UNIT_TESTS/init.ali UNIT_TESTS/init.o \
	UNIT_TESTS/mapper.ali UNIT_TESTS/mapper.o UNIT_TESTS/mapper_main \
	UNIT_TESTS/mapper_main.ali UNIT_TESTS/mapper_main.o UNIT_TESTS/test.a \
	UNIT_TESTS/test.ali UNIT_TESTS/test.o spatial_hash.ali spatial_hash.o
ext_clean:
	rm -f conf-adatype conf-cctype conf-ldtype conf-systype mk-ctxt

regen:\
ada-srcmap ada-srcmap-all
	./ada-srcmap-all
	cpj-genmk > Makefile.tmp && mv Makefile.tmp Makefile
