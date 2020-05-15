PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all: move rmd2md

move:
		cp inst/vign/rerddap.md vignettes;\
		cp inst/vign/Using_rerddap.md vignettes;\
		cp -r inst/vign/figure/ vignettes/figure/

rmd2md:
		cd vignettes;\
		mv rerddap.md rerddap.Rmd;\
		mv Using_rerddap.md Using_rerddap.Rmd

test:
	${RSCRIPT} -e 'library(methods); devtools::test()'

doc:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples(run = TRUE)"

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build . --no-build-vignettes

check: build
	_R_CHECK_CRAN_INCOMING_=FALSE R CMD check --as-cran --no-manual --no-build-vignettes `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

radme:
	${RSCRIPT} -e "knitr::knit('README.Rmd')"

# No real targets!
.PHONY: all test doc install
