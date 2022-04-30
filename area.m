function [new_x,new_y,im] = area(im,y,x,thresh)
    new_x = zeros(1,8);
    new_y = zeros(1,8);
    % grayscale value set to define the bleeding
    value = 0.2;
    % threshold coefficients
    coef = 0.1;
    coef2 = 0.1;
    %pixel above
    if ((im(y+1,x) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y+1,x)))
        new_x(1,1) = x;
        new_y(1,1) = y+1;
        im(y+1,x) = value;
    end
    %pixel on the right upper diagonal
    if ((im(y+1,x+1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y+1,x+1)))
        new_x(1,2) = x+1;
        new_y(1,2) = y+1;
        im(y+1,x+1) = value;
    end
    %pixel on the right
    if ((im(y,x+1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y,x+1)))
        new_x(1,3) = x+1;
        new_y(1,3) = y;
        im(y,x+1) = value;
    end
    %pixel on the right lower diagonal
    if ((im(y-1,x+1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y-1,x+1)))
        new_x(1,4) = x+1;
        new_y(1,4) = y-1;
        im(y-1,x+1) = value;
    end
    %pixel below
    if ((im(y-1,x) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y-1,x)))
        new_x(1,5) = x;
        new_y(1,5) = y-1;
        im(y-1,x) = value;
    end
    %pixel on the left lower diagonal
    if ((im(y-1,x-1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y-1,x-1)))
        new_x(1,6) = x-1;
        new_y(1,6) = y-1;
        im(y-1,x-1) = value;
    end
    %pixel on the left
    if ((im(y,x-1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y,x-1)))
        new_x(1,7) = x-1;
        new_y(1,7) = y;
        im(y,x-1) = value;
    end
    %pixel on the left upper diagonal
    if ((im(y+1,x-1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y+1,x-1)))
        new_x(1,8) = x-1;
        new_y(1,8) = y+1;
        im(y+1,x-1) = value;
    end
end