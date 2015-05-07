all: move rmd2md

move:
		cp inst/vign/rerddap_vignette.md vignettes/

rmd2md:
		cd vignettes;\
		mv rerddap_vignette.md rerddap_vignette.Rmd
