function [m00,m10,m01,mu11,mu20,mu02] = ComputeMoment(X,Y,N)

if (length(X)~=length(Y))||(length(X)~=N)
    print('No match in Input Size')
end

m00=N;
m10=sum(X);
m01=sum(Y);
mu11=sum((X-repmat(m10/m00,size(X))).*(Y-repmat(m01/m00,size(Y))));
mu20=sum((X-repmat(m10/m00,size(X))).*(X-repmat(m10/m00,size(X))));
mu02=sum((Y-repmat(m01/m00,size(Y))).*(Y-repmat(m01/m00,size(Y))));

end

