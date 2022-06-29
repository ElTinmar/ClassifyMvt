function [ d2 ] = DTWFunc( Xi,Xj )

w=10;
d2=zeros(size(Xj,1),1);
for k=1:size(Xj,1)
    d2(k)=cdtw_dist(Xi,Xj(k,:),w);%dtw_c(Xi,Xj(k,:),w);
end




end

