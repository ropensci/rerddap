all: move rmd2md

move:
		cp inst/vign/rerddap_vignette.md vignettes;\
		cp inst/vign/Using_rerddap.md vignettes;\
		cp -r inst/vign/figure/ vignettes/figure/

rmd2md:
		cd vignettes;\
		mv rerddap_vignette.md rerddap_vignette.Rmd;\
		mv Using_rerddap.md Using_rerddap.Rmd
