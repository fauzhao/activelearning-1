
w = -4:4;
w = cat(1,ones(size(w)),w);

figure;hold on
for wind = 1:size(w,2)
x = -10:.1:10;
y = 1./(1+exp(-(w(2,wind)*x+w(1,wind))));
plot(x,y)
end