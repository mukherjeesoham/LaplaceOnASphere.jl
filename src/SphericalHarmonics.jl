#---------------------------------------------------------------
# LaplaceOnASphere
# Soham 3/20
# Compute scalar and tensor spherical harmonics
# Ψ = ∇Y
# Φ = e^b_a ∇Y
#---------------------------------------------------------------

using GSL
export ScalarSPH, dYdθ, dYdϕ, GradSH, CurlSH
abstol = 1e-8

function unpack(x::gsl_sf_result)
    return x.val, x.err
end

function safe_sf_legendre_sphPlm_e(l::Int, m::Int, θ::T)::T where {T}
    if abs(m) > l
        Yl = 0
    else
        Yl, E = unpack(sf_legendre_sphPlm_e(l, abs(m), cos(θ)))
        Yl = m < 0 && isodd(m) ? -Yl : Yl
        try
            @assert isless(abs(E), abstol)
        catch
            @show l, m, θ, E
            @assert isless(abs(E), abstol)
        end
    end
    return Yl
end

function ScalarSPH(l::Int, m::Int, θ::T, ϕ::T)::Complex{T} where {T}
    Yl = safe_sf_legendre_sphPlm_e(l, m, θ)
    return Yl*cis(m*ϕ) 
end

function dYdθ(l::Int, m::Int, θ::T, ϕ::T)::Complex{T} where {T}
    return m*cot(θ)*ScalarSPH(l,m,θ,ϕ) + sqrt((l-m)*(l+m+1))*cis(-ϕ)*ScalarSPH(l,m+1,θ,ϕ)
end

function dYdϕ(l::Int, m::Int, θ::T, ϕ::T)::Complex{T} where {T}
    return im*m*ScalarSPH(l,m,θ,ϕ)
end

function GradSH(a::Int, l::Int, m::Int, θ::T, ϕ::T)::Complex{T} where {T}
    if a  == 1
        return dYdθ(l,m,θ,ϕ)
    elseif a == 2
        return dYdϕ(l,m,θ,ϕ)
    end
end

function CurlSH(a::Int, l::Int, m::Int, θ::T, ϕ::T)::Complex{T} where {T}
    if a  == 1
        return  dYdϕ(l,m,θ,ϕ)
    elseif  a == 2
        return -dYdθ(l,m,θ,ϕ)
    end
end

