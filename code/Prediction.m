function [PEx,PEy,XiPos,XjPos,YiPos,YjPos,NL] = Prediction(I,N,layer)
[A,B] = size(I);

NL = zeros(1,N); % �����Ӷ�
PEx = zeros(1,N); % Ԥ����� e(2i-1)
PEy = zeros(1,N); % Ԥ����� e(2i)
XiPos = zeros(1,N); % e(2i-1)���к�
XjPos = zeros(1,N); % e(2i-1)���к�
YiPos = zeros(1,N); % e(2i)���к�
YjPos = zeros(1,N); % e(2i)���к�

% ����Ԥ��
if layer == 1 % case1: ��һ��Ƕ��
    t = 1; 
    for i = 2:2:A-2
        for j = 2:2:B-2

                            p1 = I(i-1,j);                  p2 = I(i-1,j+2);                 
            p3 = I(i,j-1);  x1 = I(i,j);   p4 = I(i,j+1);   p5 = I(i,j+2);
                            p6 = I(i+1,j); x2 = I(i+1,j+1); p7 = I(i+1,j+2);
            p8 = I(i+2,j-1);p9 = I(i+2,j); p10 =I(i+2,j+1); p11= I(i+2,j+2);
            
            % ���㸴�Ӷ�
            NL(t) = abs(p3-p8)+abs(p1-p6)+abs(p6-p9)+abs(p4-p10)+abs(p2-p5)+abs(p5-p7)+abs(p7-p11);
            NL(t) = NL(t)+abs(p1-p2)+abs(p3-p4)+abs(p4-p5)+abs(p6-p7)+abs(p8-p9)+abs(p10-p9)+abs(p10-p11);
            NL(t) = NL(t)+abs(p1-p3)+abs(p1-p4)+abs(p4-p2)+abs(p6-p3)+abs(p4-p6)+abs(p4-p7)+abs(p6-p8)+abs(p6-p10)+abs(p7-p10);
            
            % Ԥ������
            PEx(t) = x1 - ceil((p1+p6+p3+p4)/4);
            PEy(t) = x2 - ceil((p4+p10+p6+p7)/4);
            
            % ��¼���к�
            XiPos(t) = i;   XjPos(t) = j;
            YiPos(t) = i+1; YjPos(t) = j+1;
            t = t+1;
        end
    end
else % case2: �ڶ���Ƕ��
    t = 1;
    for i = 2:2:A-2
        for j = 3:2:B-1
            
      
            p1 = I(i-1,j-2);                  p2 = I(i-1,j);               
                             p3 = I(i,j-1);   x1 = I(i,j);   p4 = I(i,j+1);
            p5 = I(i+1,j-2); x2 = I(i+1,j-1); p6 = I(i+1,j); p7 = I(i+1,j+1); 
            p8 = I(i+2,j-2); p9 = I(i+2,j-1); p10= I(i+2,j); p11= I(i+2,j+1);
            
            % ���㸴�Ӷ�
            NL(t) = abs(p1-p5)+abs(p5-p8)+abs(p3-p9)+abs(p2-p6)+abs(p6-p10)+abs(p4-p7)+abs(p7-p11);
            NL(t) = NL(t)+abs(p1-p2)+abs(p3-p4)+abs(p5-p6)+abs(p6-p7)+abs(p8-p9)+abs(p10-p9)+abs(p10-p11);
            NL(t) = NL(t)+abs(p1-p3)+abs(p2-p3)+abs(p3-p5)+abs(p3-p6)+abs(p4-p6)+abs(p5-p9)+abs(p6-p9)+abs(p6-p11)+abs(p7-p10);
            
            % Ԥ������
            PEx(t) = x1 - ceil((p6+p2+p3+p4)/4);
            PEy(t) = x2 - ceil((p9+p3+p6+p5)/4);
            
            % ��¼���к�
            XiPos(t) = i;   XjPos(t) = j;
            YiPos(t) = i+1; YjPos(t) = j-1;
            t = t+1;
        end
    end
end

% ͬ����λ�����㴦��ͬ����
PEx = PEx+0.5;
PEy = PEy+0.5;


end

