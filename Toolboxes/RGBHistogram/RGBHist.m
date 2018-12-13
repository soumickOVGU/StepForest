function [ hR, hG, hB ] = RGBHist( im )
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    hR = imhist(R);
    hG = imhist(G);
    hB = imhist(B);
end

