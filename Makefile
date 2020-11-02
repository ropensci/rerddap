PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

vign:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('rerddap.Rmd.og', output = 'rerddap.Rmd')";\
	cd ..

vign_using_rerddap:
	cd vignettes;\
	${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('Using_rerddap.Rmd.og', output = 'Using_rerddap.Rmd')";\
	cd ..

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
	R CMD build .

check: build
	_R_CHECK_CRAN_INCOMING_=FALSE R CMD check --as-cran --no-manual `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

check_windows:
	${RSCRIPT} -e "devtools::check_win_devel(); devtools::check_win_release()"

readme:
	${RSCRIPT} -e "knitr::knit('README.Rmd')"

# No real targets!
.PHONY: all test doc install
