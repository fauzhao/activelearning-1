function full_im = add_plus(full_im)
imSize = 1200;  
focal_length = 10;
focal_width = 2;

full_im(imSize/2-focal_width:imSize/2+focal_width,...
    imSize-focal_length:imSize+focal_length) = 1;
full_im(imSize/2-focal_length:imSize/2+focal_length,...
    imSize-focal_width:imSize+focal_width) = 1;
end