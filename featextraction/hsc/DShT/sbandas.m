function [d1 d2] = sbandas(img)

    img = double(img);
    xlo = img;
    [xlo d1] = sdec(xlo, 3, 8);
    [xlo d2] = sdec(xlo, 3, 8);
end
