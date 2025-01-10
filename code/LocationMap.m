function [LM,data,I] = LocationMap(I,layer)
%LOCATIONMAP 此处显示有关此函数的摘要
%   此处显示详细说明
[d1,d2] = size(I);
flow_map = [];
if layer == 1
    for i=2:2:d1-2
        for j=2:2:d2-2
            pe = I(i,j)-ceil((I(i-1,j)+I(i+1,j)+I(i,j-1)+I(i,j+1))/4);
            ind = (i-1)*d2 + j;
            if I(i,j) ==255
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 1];
               continue
            end
            if I(i,j) ==254
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 0];
               continue
            end
            if pe<=-1 && I(i,j) ==0
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 1];
               continue
            end
            if pe<=-1 && I(i,j) ==1
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 0];
               continue
            end
        end
    end
    for i=3:2:d1-1
        for j=3:2:d2-1
            pe = I(i,j)-ceil((I(i-1,j)+I(i+1,j)+I(i,j-1)+I(i,j+1))/4);
            ind = (i-1)*d2 + j;
            if pe>=0 && I(i,j) ==255
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 1];
               continue
            end
            if pe>=0 && I(i,j) ==254
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 0];
               continue
            end
            if pe<=-1 && I(i,j) ==0
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 1];
               continue
            end
            if pe<=-1 && I(i,j) ==1
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 0];
               continue
            end
        end
    end
else
    for i=3:2:d1-1
        for j=2:2:d2-2
            pe = I(i,j)-ceil((I(i-1,j)+I(i+1,j)+I(i,j-1)+I(i,j+1))/4);
            ind = (i-1)*d2 + j;
            if I(i,j) ==255
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 1];
               continue
            end
            if I(i,j) ==254
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 0];
               continue
            end
            if I(i,j) ==0
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 1];
               continue
            end
            if I(i,j) ==1
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 0];
               continue
            end
        end
    end

    for i=3:2:d1-1
        for j=2:2:d2-2
            pe = I(i,j)-ceil((I(i-1,j)+I(i+1,j)+I(i,j-1)+I(i,j+1))/4);
            ind = (i-1)*d2 + j;
            if I(i,j) ==255
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 1];
               continue
            end
            if I(i,j) ==254
               I(i,j) = I(i,j) - 1;
               flow_map = [flow_map 0];
               continue
            end
            if I(i,j) ==0
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 1];
               continue
            end
            if I(i,j) ==1
               I(i,j) = I(i,j) + 1;
               flow_map = [flow_map 0];
               continue
            end
        end
    end
end
LM = flow_map;
xC = cell(1,1);
xC{1} = LM;
data = arith07(xC);
t = 1;
end

