function [xlo d] = sdec(img, num, n1)

    [h, g] = pfilters('Burt');
    [xlo, xhi] = lpdec(double(img), h, g);
    w_s = shearing_filters_Myer(n1,num);
    for k=1:2^num,
        shear_f(:,:,k)=real(fftshift(ifft2(fftshift(w_s(:,:,k)))));
        d(:,:,k)=conv2(xhi,squeeze(shear_f(:,:,k)),'same');
    end
end
