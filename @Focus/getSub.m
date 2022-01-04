function K = getSub(this, t, x, y, w)

if isinteger([x y])

    K = fSub(this.mmap.Data(t).frame, x, y, w);
    
else
    
    xi = floor(x);
    yi = floor(y);

    tmp = fSub(this.mmap.Data(t).frame, xi, yi, w+2);
    tmp = imtranslate(tmp, [x-xi y-yi]);
    K = tmp(2:end-1, 2:end-1);

end

end

% -------------------------------------------------------------------------
function Sub = fSub(Img, x, y, w)

a = (w-1)/2;

x1 = max(round(x-a),1);
x2 = min(round(x+a),size(Img,2));
y1 = max(round(y-a),1);
y2 = min(round(y+a),size(Img,1));

Sub = Img(y1:y2, x1:x2);

% Padding
if x1<a, Sub = [zeros(size(Sub,1),w-size(Sub,2)) Sub]; end
if x2>size(Sub,2)-a, Sub = [Sub zeros(size(Sub,1),w-size(Sub,2))]; end
if y1<a, Sub = [zeros(w-size(Sub,1),size(Sub,2)) ; Sub]; end
if y2>size(Sub,2)-a, Sub = [Sub ; zeros(w-size(Sub,1),size(Sub,2))]; end

end
