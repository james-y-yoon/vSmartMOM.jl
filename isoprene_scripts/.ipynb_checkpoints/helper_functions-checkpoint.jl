using Pkg.Artifacts
using NCDatasets
using ProgressMeter
using Distributions
using Interpolations
using Polynomials

using vSmartMOM.Absorption
using Parameters
using DelimitedFiles
using ForwardDiff, DiffResults

abstract type InstrumentOperator end

"Struct for an atmospheric profile"
struct AtmosphericProfile{FT}
    lat::FT
    lon::FT
    psurf::FT
    T::Array{FT,1}
    q::Array{FT,1}
    p::Array{FT,1}
    p_levels::Array{FT,1}
    vmr_h2o::Array{FT,1}
    vcd_dry::Array{FT,1}
    vcd_h2o::Array{FT,1}
end;

"Read atmospheric profile (just works for our file, can be generalized"
function read_atmos_profile(file::String, lat::Real, lon::Real, timeIndex; g₀=9.8196)
    @assert 1 <= timeIndex <= 4

    ds = Dataset(file)

    # See how easy it is to actually extract data? Note the [:] in the end reads in ALL the data in one step
    lat_   = ds["lat"][:]
    lon_   = ds["lon"][:]
    
    FT = eltype(lat_)
    lat = FT(lat)
    lon = FT(lon)
    
    # Find index (nearest neighbor, one could envision interpolation in space and time!):
    iLat = argmin(abs.(lat_ .- lat))
    iLon = argmin(abs.(lon_ .- lon))
    @show ds["T"]
    
    # Temperature profile
    T    = convert(Array{FT,1}, ds["T"][ iLon,iLat, :, timeIndex])
    # specific humidity profile
    q    = convert(Array{FT,1}, ds["QV"][iLon,iLat,  :, timeIndex])
    
    # Surafce pressure
    psurf = convert(FT, ds["PS"][iLon, iLat, timeIndex])

    # AK and BK global attributes (important to calculate pressure half-levels)
    ak = ds.attrib["ak"][:]
    bk = ds.attrib["bk"][:]

    p_half = (ak + bk * psurf)
    p_full = (p_half[2:end] + p_half[1:end - 1]) / 2
    close(ds)

    # Avogradro's number:
    Na = 6.0221415e23;
    # Dry and wet mass
    dryMass = 28.9647e-3  / Na  # in kg/molec, weighted average for N2 and O2
    wetMass = 18.01528e-3 / Na  # just H2O
    ratio = dryMass / wetMass 
    n_layers = length(T)
    # also get a VMR vector of H2O (volumetric!)
    vmr_h2o = zeros(FT, n_layers, )
    vcd_dry = zeros(FT, n_layers, )
    vcd_h2o = zeros(FT, n_layers, )

    # Now actually compute the layer VCDs
    for i = 1:n_layers 
        Δp = p_half[i + 1] - p_half[i]
        vmr_h2o[i] = q[i] * ratio
        vmr_dry = 1 - vmr_h2o[i]
        M  = vmr_dry * dryMass + vmr_h2o[i] * wetMass
        vcd_dry[i] = vmr_dry * Δp / (M * g₀ * 100.0^2)   # includes m2->cm2
        vcd_h2o[i] = vmr_h2o[i] * Δp / (M * g₀ * 100^2)
    end

    return AtmosphericProfile(lat, lon, psurf, T, q, p_full, p_half, vmr_h2o, vcd_dry, vcd_h2o)
end;


"Computes cross section matrix for arbitrary number of absorbers"
function compute_profile_crossSections_isoprene(
        profile::AtmosphericProfile, 
        hitranModels :: Array{vSmartMOM.Absorption.HitranModel}, 
        ν::AbstractRange{<:Real})
    
    nGases   = length(hitranModels)
    nProfile = length(profile.p)
    FT = eltype(profile.T)
    n_layers = length(profile.T)

    σ_matrix = zeros(FT, (length(ν), n_layers, nGases))
    for i = 1:n_layers
        p_ = profile.p[i] / 100 # in hPa
        T_ = profile.T[i]
        for j = 1:nGases
            σ_matrix[:,i,j] = vSmartMOM.Absorption.absorption_cross_section_isoprene(hitranModels[j], ν, p_, T_);
        end
    end
    return σ_matrix
end;

"Computes cross section matrix for arbitrary number of absorbers"
function compute_profile_crossSections(
        profile::AtmosphericProfile, 
        hitranModels :: Array{vSmartMOM.Absorption.HitranModel}, 
        ν::AbstractRange{<:Real})
    
    nGases   = length(hitranModels)
    nProfile = length(profile.p)
    FT = eltype(profile.T)
    n_layers = length(profile.T)

    σ_matrix = zeros(FT, (length(ν), n_layers, nGases))
    for i = 1:n_layers
        p_ = profile.p[i] / 100 # in hPa
        T_ = profile.T[i]
        for j = 1:nGases
            σ_matrix[:,i,j] = vSmartMOM.Absorption.absorption_cross_section(hitranModels[j], ν, p_, T_);
        end
    end
    return σ_matrix
end;

"Reduce profile dimensions"
function reduce_profile(n::Int, profile::AtmosphericProfile)
    @unpack lat, lon, psurf = profile
    FT = eltype(profile.T)
    # New rough half levels (boundary points)
    a = range(0, maximum(profile.p), length=n + 1)
    T = zeros(FT, n);
    q = zeros(FT, n);
    p_full = zeros(FT, n);
    p_levels = zeros(FT, n + 1);
    vmr_h2o  = zeros(FT, n);
    vcd_dry  = zeros(FT, n);
    vcd_h2o  = zeros(FT, n);

    for i = 1:n
        ind = findall(a[i] .< profile.p .<= a[i + 1]);
        p_levels[i] = profile.p_levels[ind[1]]
        p_levels[i + 1] = profile.p_levels[ind[end]]
        p_full[i] = mean(profile.p_levels[ind])
        T[i] = mean(profile.T[ind])
        q[i] = mean(profile.q[ind])
        vmr_h2o[i] = mean(profile.vmr_h2o[ind])
        vcd_dry[i] = sum(profile.vcd_dry[ind])
        vcd_h2o[i] = sum(profile.vcd_h2o[ind])
    end

    return AtmosphericProfile(lat, lon, psurf, T, q, p_full, p_levels, vmr_h2o, vcd_dry, vcd_h2o)
end;

"Reads in MERRA2 data"
function retrieve_merra2_conditions(date, startTime, lat, lon)
    # Feel free to change the MERRA2 file and folder paths
    MerraFile = "MERRA2_400.inst6_3d_ana_Nv." * date * ".nc4";
    MerraFolder = "MERRA2/";
    MerraFilePath = joinpath(MerraFolder, MerraFile);
    
    # These files have 00, 06, 12 or 18 in UTC, i.e. 6 hourly data stacked together
    hour = parse(Int, chop(startTime));
    hour_index = Int(hour / 6);

    # Read atmos profile (from helperfunctions.jl)
    return read_atmos_profile(MerraFilePath, lat, lon, hour_index);
end

function retrieve_merra2_skin_temperature(date, startTime, lat, lon)
    MerraFile = "MERRA2_400.inst1_2d_asm_Nx." * date * ".nc4";
    MerraFolder = "MERRA2/skin_temperature";
    MerraFilePath = joinpath(MerraFolder, MerraFile);

    hour = parse(Int, chop(startTime));
    timeIndex = Int(hour);

    ds = Dataset(MerraFilePath)

    # See how easy it is to actually extract data? Note the [:] in the end reads in ALL the data in one step
    lat_   = ds["lat"][:]
    lon_   = ds["lon"][:]
    
    FT = eltype(lat_)
    lat = FT(lat)
    lon = FT(lon)

    # Find index (nearest neighbor, one could envision interpolation in space and time!):
    iLat = argmin(abs.(lat_ .- lat))
    iLon = argmin(abs.(lon_ .- lon))

    skin_temperature  = ds["TS"][ iLon,iLat, timeIndex]
    
    close(ds)
    return skin_temperature
end


"Planck function (returns in mW/m²-sr-cm⁻¹)"
function planck_spectrum_wn_i(T::Real, ν_grid)
    c1 = 1.1910427 * 10^(-5)    # mW/m²-sr-cm⁻¹
    c2 = 1.4387752              # K⋅cm

    # L(ν, T) = c1⋅ν³/(exp(c2⋅ν/T) - 1)
    radiance = c1 .* (ν_grid.^3) ./ (exp.(c2 * ν_grid / T) .- 1) ./ 1000 # Returns in W/m²-sr-cm⁻¹

    return radiance
end