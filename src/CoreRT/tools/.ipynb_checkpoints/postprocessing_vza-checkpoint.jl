#=

This file contains the function to perform azimuthal-weighting to the RT matrices after all 
kernel calculations. 

=#

"Perform post-processing to azimuthally-weight RT matrices"
function postprocessing_vza!(RS_type::noRS, iμ₀, pol_type, 
        composite_layer, vza, qp_μ, m, vaz, μ₀, weight, 
        nSpec, SFI, R, R_SFI, T, T_SFI,ieR_SFI, ieT_SFI)
    
    # idx of μ0 = cos(sza)
    st_iμ0, istart0, iend0 = get_indices(iμ₀, pol_type);

    # Convert these to Arrays (if CuArrays), so they can be accessed by index
    R⁻⁺ = Array(composite_layer.R⁻⁺);
    T⁺⁺ = Array(composite_layer.T⁺⁺);
    J₀⁺ = Array(composite_layer.J₀⁺);
    J₀⁻ = Array(composite_layer.J₀⁻);
    
    minUp = 0.0;
    maxUp = 0.0;
    # Loop over all viewing zenith angles
    for i = 1:length(vza)

        # Find the nearest quadrature point idx
        iμ = nearest_point(qp_μ, cosd(vza[i]));
        st_iμ, istart, iend = get_indices(iμ, pol_type);
        
        # Compute bigCS
        cos_m_phi, sin_m_phi = (cosd(m * vaz[i]), sind(m * vaz[i]));
        bigCS = weight * Diagonal([cos_m_phi, cos_m_phi, sin_m_phi, sin_m_phi][1:pol_type.n]);

        #@show J₀⁻[istart:iend,1, 1], J₀⁺[istart:iend,1, 1]
        # Accumulate Fourier moments after azimuthal weighting
        for s = 1:nSpec
            
            if SFI
                dR  = bigCS * J₀⁻[istart:iend,1, s]
                dRR = dR ./ R_SFI[i,:,s]
                if dRR[1] < minUp 
                    minUp = dRR[1]
                elseif dRR[1] > maxUp 
                    maxUp = dRR[1]
                end
            
                R_SFI[i,:,s] .+= dR;
                T_SFI[i,:,s] .+= bigCS * J₀⁺[istart:iend,1, s];
            else
                R[i,:,s] .+= bigCS * (R⁻⁺[istart:iend, istart0:iend0, s] / μ₀) * pol_type.I₀;
                T[i,:,s] .+= bigCS * (T⁺⁺[istart:iend, istart0:iend0, s] / μ₀) * pol_type.I₀;
            end
        end
    end
    
    if m>0
        @info "Radiance Δ range in %: from $(minUp*100) to $(maxUp*100) for m=$(m)" 
    end
end

"RAMI: Perform post-processing to azimuthally-weight hdr matrices"
function postprocessing_vza_hdrf!(RS_type::noRS, iμ₀, pol_type, 
        hdr_J₀⁻,  vza, qp_μ, m, vaz, μ₀, weight, 
        nSpec, hdr)
    
    # idx of μ0 = cos(sza)
    st_iμ0, istart0, iend0 = get_indices(iμ₀, pol_type);

    # Convert these to Arrays (if CuArrays), so they can be accessed by index
    hdr_J₀⁻ = Array(hdr_J₀⁻);
    
    minUp = 0.0;
    maxUp = 0.0;
    # Loop over all viewing zenith angles
    for i = 1:length(vza)

        # Find the nearest quadrature point idx
        iμ = nearest_point(qp_μ, cosd(vza[i]));
        st_iμ, istart, iend = get_indices(iμ, pol_type);
        
        # Compute bigCS
        cos_m_phi, sin_m_phi = (cosd(m * vaz[i]), sind(m * vaz[i]));
        bigCS = weight * Diagonal([cos_m_phi, cos_m_phi, sin_m_phi, sin_m_phi][1:pol_type.n]);

        #@show J₀⁻[istart:iend,1, 1], J₀⁺[istart:iend,1, 1]
        # Accumulate Fourier moments after azimuthal weighting
        for s = 1:nSpec
            dR  = bigCS * hdr_J₀⁻[istart:iend,1, s]
            hdr[i,:,s] .+= dR;                
        end
    end
end

function postprocessing_vza!(RS_type::Union{RRS, VS_0to1_plus, VS_1to0_plus}, 
        iμ₀, pol_type, composite_layer, 
        vza, qp_μ, m, vaz, μ₀, weight, 
        nSpec, SFI, R, R_SFI, T, T_SFI, ieR_SFI, ieT_SFI)
    
    # idx of μ0 = cos(sza)
    st_iμ0, istart0, iend0 = get_indices(iμ₀, pol_type);

    # Convert these to Arrays (if CuArrays), so they can be accessed by index
    R⁻⁺ = Array(composite_layer.R⁻⁺);
    T⁺⁺ = Array(composite_layer.T⁺⁺);
    J₀⁺ = Array(composite_layer.J₀⁺);
    J₀⁻ = Array(composite_layer.J₀⁻);

    #ieR⁻⁺ = Array(composite_layer.ieR⁻⁺);
    #ieT⁺⁺ = Array(composite_layer.ieT⁺⁺);
    ieJ₀⁺ = Array(composite_layer.ieJ₀⁺);
    ieJ₀⁻ = Array(composite_layer.ieJ₀⁻);
    # Loop over all viewing zenith angles
    

    for i = 1:length(vza)

        # Find the nearest quadrature point idx
        iμ = nearest_point(qp_μ, cosd(vza[i]));
        st_iμ, istart, iend = get_indices(iμ, pol_type);
        
        # Compute bigCS
        cos_m_phi, sin_m_phi = (cosd(m * vaz[i]), sind(m * vaz[i]));
        bigCS = weight * Diagonal([cos_m_phi, cos_m_phi, sin_m_phi, sin_m_phi][1:pol_type.n]);

        # Accumulate Fourier moments after azimuthal weighting
        for s = 1:nSpec
            
            if SFI
                R_SFI[i,:,s] += bigCS * J₀⁻[istart:iend,1, s];
                T_SFI[i,:,s] += bigCS * J₀⁺[istart:iend,1, s];
                #@show i, s, R_SFI[i,:,s]
                #@show i, s, ieR_SFI[i,:,s]
                for t =1:size(ieJ₀⁺,4)# in eachindex ieJ₀⁺[1,1,1,:]
                    ieR_SFI[i,:,s] += bigCS * ieJ₀⁻[istart:iend,1, s, t];
                    ieT_SFI[i,:,s] += bigCS * ieJ₀⁺[istart:iend,1, s, t];
                    #@show i, s, t, ieR_SFI[i,:,s]
                end
                #@show i, s, ieR_SFI[i,:,s]
            else
                R[i,:,s] += bigCS * (R⁻⁺[istart:iend, istart0:iend0, s] / μ₀) * pol_type.I₀;
                T[i,:,s] += bigCS * (T⁺⁺[istart:iend, istart0:iend0, s] / μ₀) * pol_type.I₀;
                #no modification for Raman because SFI will be the only mode used for inelastic computations
            end
            
        end
    end
end