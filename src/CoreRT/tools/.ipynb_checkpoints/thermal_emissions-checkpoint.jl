"""      
    planck_spectrum_wn(T::Real, ν_grid::Vector)
    
    Produce the black-body planck spectrum (mW/m²-sr-cm⁻¹), given the temperature (K) 
    and calculation grid (ν in cm⁻¹)
"""
function planck_spectrum_wn(T::Real, ν_grid::Vector{Float64})
    c1 = 1.1910427 * 10^(-5)    # mW/m²-sr-cm⁻¹
    c2 = 1.4387752              # K⋅cm

    # L(ν, T) = c1⋅ν³/(exp(c2⋅ν/T) - 1)
    radiance = c1 .* (ν_grid.^3) ./ (exp.(c2 * ν_grid / T) .- 1)

    return radiance
end
