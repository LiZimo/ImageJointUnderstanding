
function smp = evenSample(nsrc, ntgt)

if nsrc > ntgt
    smp = round((0:ntgt-1) .* (nsrc/ntgt) + (nsrc/ntgt)/2);
else
    smp = 1:nsrc;
end


