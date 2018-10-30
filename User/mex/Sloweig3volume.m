function [L1x,L1y,L1z,L2x,L2y,L2z,L3x,L3y,L3z,Lambda1,Lambda2,Lambda3] = Sloweig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz)
%This function eig2image calculates the eigen values from the
% hessian matrix, sorted by abs value

[x,y,z]=size(Dxx);
Lambda1=zeros(x,y,z);
Lambda2=zeros(x,y,z);
Lambda3=zeros(x,y,z);
L1x=zeros(x,y,z);
L1y=zeros(x,y,z);
L1z=zeros(x,y,z);
L2x=zeros(x,y,z);
L2y=zeros(x,y,z);
L2z=zeros(x,y,z);
L3x=zeros(x,y,z);
L3y=zeros(x,y,z);
L3z=zeros(x,y,z);

for i=1:x
    for j=1:y
        for k=1:z
            
%  compute the eigenvalue of Hessian matrix
            Hessian=[Dxx(i,j,k),Dxy(i,j,k),Dxz(i,j,k);Dxy(i,j,k),Dyy(i,j,k),Dyz(i,j,k);Dxz(i,j,k),Dyz(i,j,k),Dzz(i,j,k)];
            e=eig(Hessian);
            [v,d]=eig(Hessian);
            
%  sort the eigen values
            ee(1)=abs(e(1));
            ee(2)=abs(e(2));
            ee(3)=abs(e(3));
            
            [sort_e,pos]=sort(ee);
      
%  sort the eigen vectors
            L1x(i,j,k)=v(1,pos(1));
            L1y(i,j,k)=v(2,pos(1));
            L1z(i,j,k)=v(3,pos(1));
            L2x(i,j,k)=v(1,pos(2));
            L2y(i,j,k)=v(2,pos(2));
            L2z(i,j,k)=v(3,pos(2));
            L3x(i,j,k)=v(1,pos(3));
            L3y(i,j,k)=v(2,pos(3));
            L3z(i,j,k)=v(3,pos(3));
            
% output the eigen values
            Lambda1(i,j,k)=e(pos(1));
            Lambda2(i,j,k)=e(pos(2));
            Lambda3(i,j,k)=e(pos(3));
        end
    end
end
Lambda1=single(Lambda1);
Lambda2=single(Lambda2);
Lambda3=single(Lambda3);
L1x=single(L1x);
L1y=single(L1y);
L1z=single(L1z);
L2x=single(L2x);
L2y=single(L2y);
L2z=single(L2z);
L3x=single(L3x);
L3y=single(L3y);
L3z=single(L3z);
