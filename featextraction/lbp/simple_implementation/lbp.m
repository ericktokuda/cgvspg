function output = lbp(im)

data = im.data; %use pixel data
%reduce center pixel value from the entire block
data = data - data(2,2);

%threshold data
data(data>=0) = 1;
data(data<0) = 0;

%build kernel of powers of two, clockwise
kernel =double([1 2 4;128 0 8;64 32 16]);

output = sum(sum(data .* kernel));


