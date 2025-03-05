
<h1 align="center">
  <br>
  <a href="https://github.com/RemoteSensingTools/vSmartMOM.jl"><img src="docs/src/assets/logo.png" alt="vSmartMOM" width="200"></a>
  <br>
  vSmartMOM.jl
  <br>
</h1>

<div align="center">
<h4 align="center">An end-to-end modular software suite for vectorized atmospheric radiative transfer calculations, based on the Matrix Operator Method. </h4>
<h5 align="center">Written in <a href="https://julialang.org">Julia</a>.</h4>

[![version](https://github.com/RemoteSensingTools/vSmartMOM.jl/actions/workflows/AutomatedTests.yml/badge.svg)](https://github.com/RemoteSensingTools/vSmartMOM.jl/actions/workflows/AutomatedTests.yml/)
  [![](https://img.shields.io/badge/docs-latest-blue)](https://RemoteSensingTools.github.io/vSmartMOM.jl/dev/)
  [![](https://img.shields.io/github/license/RemoteSensingTools/vSmartMOM.jl)](https://github.com/RemoteSensingTools/vSmartMOM.jl/blob/master/LICENSE)
  [![DOI](https://joss.theoj.org/papers/10.21105/joss.04575/status.svg)](https://doi.org/10.21105/joss.04575)
  [![](https://img.shields.io/github/commit-activity/y/RemoteSensingTools/vSmartMOM.jl)](https://github.com/RemoteSensingTools/vSmartMOM.jl/commits/master)
</div>

<div align="left">
## Version
This version contains thermal emissions (Planck function fluxes from every layer and the surface) and isoprene as another absorption species. 

Isoprene was added via pseudo-line-lists obtained from [this database](https://mark4sun.jpl.nasa.gov/pseudo.html). More information about the isoprene pseudo-line-list can be found [here](https://mark4sun.jpl.nasa.gov/data/spec/Pseudo/Isoprene_PLL-compressed.pdf). 

### How to add additional species with pseudo-line-lists

To add additional species that are not in the HITRAN line list database, you must create functions (similar to the isoprene functions) in:

- **Absorption/read_hitran.jl**: This function must be tailored to your specific pseudo-line-list and the fields it contains.
- **Absorption/compute_absorption_cross_section.jl**: Almost identical to the regular compute_absorption_cross_section function, but you need to specify your molecule's molar mass. Also note that this version does not adjust the absorption cross sections by the total internal partition sums.
- **Absorption/autodiff_helper.jl**: Just a wrapper function that directs the program toward your new compute_absorption_cross_section function.
- **CoreRT/tools/atmo_prof.jl**: Another function that just redirects the program to your new absorption_cross_section function.

In addition to new functions in the above files, you will need to add your molecule to the code within **CoreRT/tools/model_from_parameters.jl**.
- if ( params.absorption_params.molecules[i_band][molec_i] == your_new_molecule ) run your_newcompute_absorption_profile_func().

</div>

## Acknowledgements

This project is being developed in the Christian Frankenberg and Paul Wennberg labs at Caltech and is largely based on papers and ideas by Suniti Sanghavi from NASA/JPL, with support from the Schmidt Academy for Software Engineering (SASE).

## Copyright Notice

Apache 2.0 License; Copyright 2022, by the California Institute of Technology. United States Government Sponsorship acknowledged.
