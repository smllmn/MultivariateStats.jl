using MultivariateStats
using Base.Test

srand(15678)

## icagfun

f = icagfun(:tanh)
u, v = evaluate(f, 1.5)
@test u ≈ 0.905148253644866438242
@test v ≈ 0.180706638923648530597

f = icagfun(:tanh, 1.5)
u, v = evaluate(f, 1.2)
@test u ≈ 0.946806012846268289646
@test v ≈ 0.155337561057228069719

f = icagfun(:gaus)
u, v = evaluate(f, 1.5)
@test u ≈ 0.486978701037524594696
@test v ≈ -0.405815584197937162246


## data

# sources
n = 1000
k = 3
m = 8

t = linspace(0.0, 10.0, n)
s1 = sin.(t * 2)
s2 = s2 = 1.0 - 2.0 * Bool[isodd(floor(Int, x / 3)) for x in t]
s3 = Float64[mod(x, 5.0) for x in t]

s1 += 0.1 * randn(n)
s2 += 0.1 * randn(n)
s3 += 0.1 * randn(n)

S = hcat(s1, s2, s3)'
@assert size(S) == (k, n)

A = randn(m, k)

X = A * S
mv = vec(mean(X,2))
@assert size(X) == (m, n)
C = cov(X, 2)

# FastICA

M = fit(ICA, X, k; do_whiten=false)
@test isa(M, ICA)
@test indim(M) == m
@test outdim(M) == k
@test mean(M) == mv
W = M.W
@test transform(M, X) ≈ W' * (X .- mv)
@test W'W ≈ eye(k)

M = fit(ICA, X, k; do_whiten=true)
@test isa(M, ICA)
@test indim(M) == m
@test outdim(M) == k
@test mean(M) == mv
W = M.W
@test W'C * W ≈ eye(k)

