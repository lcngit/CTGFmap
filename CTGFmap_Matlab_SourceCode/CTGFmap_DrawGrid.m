%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function Img = CTGFmap_DrawGrid(Img, color, sz_grid, shftr, shftc)

[nr, nc, nb] = size (Img);
n_gridr = floor(nr / sz_grid);
n_gridc = floor(nc / sz_grid);

for i = 0 : n_gridr
    p = (i * sz_grid) + shftr;
    if p <= 0
        p = 1;
    end
    if p > nr
        p = nr;
    end
    for k = 1 : nb
        if k == color
            c = 255;
        else
            c = 0;
        end
        Img(p, : , k) = c;
    end
end

for i = 0 : n_gridc
    q = (i * sz_grid) + shftc;
    if q <= 0
        q = 1;
    end
    if q > nc
        q = nc;
    end
    for k = 1 : nb
        if k == color
            c = 255;
        else
            c = 0;
        end
        Img(: , q, k) = c;
    end
end

end

