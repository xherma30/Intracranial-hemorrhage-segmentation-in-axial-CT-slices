function [new_x,new_y,im] = area(im,y,x,thresh)
% funkce pro testovani okoli a zapis hodnot do struktury
% vstupni parametry: obraz, souradnice vych. bodu, prah
% vystupni parametry: vektory souradnic novych vych. bodu, obraz
%------------------------------------------------------------------
    % inicializace
    new_x = zeros(1,8);
    new_y = zeros(1,8);
    % hodnota zapisovana do struktury
    value = 0.2;
    % koeficienty horniho a dolniho prahu
    coef = 0.1;
    coef2 = 0.1;

    % testovani okoli
    if ((im(y+1,x) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y+1,x)))
        new_x(1,1) = x;
        new_y(1,1) = y+1;
        im(y+1,x) = value;
    end

    if ((im(y+1,x+1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y+1,x+1)))
        new_x(1,2) = x+1;
        new_y(1,2) = y+1;
        im(y+1,x+1) = value;
    end

    if ((im(y,x+1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y,x+1)))
        new_x(1,3) = x+1;
        new_y(1,3) = y;
        im(y,x+1) = value;
    end

    if ((im(y-1,x+1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y-1,x+1)))
        new_x(1,4) = x+1;
        new_y(1,4) = y-1;
        im(y-1,x+1) = value;
    end

    if ((im(y-1,x) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y-1,x)))
        new_x(1,5) = x;
        new_y(1,5) = y-1;
        im(y-1,x) = value;
    end

    if ((im(y-1,x-1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y-1,x-1)))
        new_x(1,6) = x-1;
        new_y(1,6) = y-1;
        im(y-1,x-1) = value;
    end

    if ((im(y,x-1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y,x-1)))
        new_x(1,7) = x-1;
        new_y(1,7) = y;
        im(y,x-1) = value;
    end

    if ((im(y+1,x-1) < thresh+coef*thresh) && (thresh-coef2*thresh < im(y+1,x-1)))
        new_x(1,8) = x-1;
        new_y(1,8) = y+1;
        im(y+1,x-1) = value;
    end
end