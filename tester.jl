# Activate Julia packages
using Revise;

# Imports
using Statistics,  LazyArtifacts, LinearAlgebra,  vSmartMOM;
#include("helper_functions.jl");

parameters = vSmartMOM.CoreRT.parameters_from_yaml("DefaultParameters-blackbody_radiation.yaml");
#parameters = vSmartMOM.CoreRT.parameters_from_yaml("solar_blackbody.yaml");
model = vSmartMOM.CoreRT.model_from_parameters(parameters); # Create model from the YAML file
R_default = vSmartMOM.CoreRT.rt_run(model); # Run the model
nu = model.params.spec_bands[1];

bb_280 = vSmartMOM.CoreRT.planck_spectrum_wn(280, nu) ./ 1000.
bb_250 = vSmartMOM.CoreRT.planck_spectrum_wn(250, nu) ./ 1000.

plot(nu, R_default[1][1,1,:], label="Modeled")
plot!(nu, bb_280, label="BB @ 280K")
plot!(nu, bb_250, label="BB @ 250K")
