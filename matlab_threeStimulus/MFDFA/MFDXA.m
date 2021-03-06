function [s,q,Hq,h,Dh,logFq]=MFDXA(xsignal,ysignal,m,scmin,scmax,ressc,qmin,qmax,qres)

% Multifractal detrended cross-correlation analysis (MFDXA)
%
% [s,q,Hq,h,Dh,logFq]=MFDXA(xsignal,ysignal,m,scmin,scmax,ressc,qmin,qmax,qres)
%
% Input----------------------------------------------------
%
% x_signal:     input signal 1
% y_signal      input signal 2
% m:            polynomial order for the detrending
% scmin:        lower bound of the window size s
% scmax:        upper bound of the window size s
% ressc:        number of elements in s 
% qmin          lower bound of q
% qmax          upper bound of q
% qres          number of elements in q
%
% Output---------------------------------------------------
%
% s:            scale
% q:            q-order 
% Hq:           q-generalized Hurst exponent
% h:            H�lder exponent 
% Dh:           Multifractal spectrum 
% logFq:        q-generalized scaling function F(s,q) in log coordinates
%
% ---------------------------------------------------------
% Written by Espen A. F. Ihlen (espen.ihlen@ntnu.no), 2010

if length(xsignal)~=length(ysignal),
    disp('---ERROR: xsignal and ysignal is not the same length--');
end

Fluct1=cumsum(xsignal-mean(xsignal));
FluctRev1=fliplr(Fluct1);
N=length(Fluct1);

Fluct2=cumsum(ysignal-mean(ysignal));
FluctRev2=fliplr(Fluct2);

ScaleNumb=linspace(log2(scmin),log2(scmax),ressc);
s=round(2.^ScaleNumb);
q=linspace(qmin,qmax,qres);
znumb=find(q==0);
Fq=zeros(length(s),length(q));

for ns=1:length(s),%disp(strcat('---------computing scale number_',num2str(ns)));                                                      
    Ns=floor(s(ns)\N);
    
    Var=zeros(Ns,length(q));
    Varr=zeros(Ns,length(q));
    for v=1:Ns,                                                         
        SegNumb=((((v-1)*s(ns))+1):(v*s(ns)))';
        %x_signal---------------------
        Seg1=Fluct1(SegNumb);                                             
        SegRev1=FluctRev1(SegNumb);                                      
        poly1=polyfit(SegNumb,Seg1',m);                                   
        polyr1=polyfit(SegNumb,SegRev1',m);                               
        fit1=polyval(poly1,SegNumb);                                     
        fitr1=polyval(polyr1,SegNumb);
        %y_signal-------------------------
        Seg2=Fluct2(SegNumb);                                             
        SegRev2=FluctRev2(SegNumb);                                      
        poly2=polyfit(SegNumb,Seg2',m);                                   
        polyr2=polyfit(SegNumb,SegRev2',m);                               
        fit2=polyval(poly2,SegNumb);                                     
        fitr2=polyval(polyr2,SegNumb);
        %---------------------------------------
        for nq=1:length(q),
            Var(v,nq)=((sum(((Seg1'-fit1).^2).*((Seg2'-fit2).^2)))/s(ns))^(q(nq)/4);                       
            Varr(v,nq)=((sum(((SegRev1'-fitr1).^2).*((SegRev2'-fitr2).^2)))/s(ns))^(q(nq)/4);
        end;
        clear Seg1 Seg2 SegNumb SegRev1 SegRev2 poly1 poly2 polyr1 polyr2 fit1 fit2 fitr1 fitr2     
    end;
    for nq=1:length(q),
        Fq(ns,nq)=((sum(Var(:,nq))+sum(Varr(:,nq)))/(2*Ns))^(1/q(nq));
    end
    clear  Var Varr
    Fq(ns,znumb)=(Fq(ns,znumb-1)+Fq(ns,znumb+1))./2;
end
logFq=log2(Fq);
Hq=zeros(1,length(q));
for nq=1:length(q),
    P=polyfit(log2(s'),log2(Fq(:,nq)),1);
    Hq(nq)=P(1);
end;

tau=(q.*Hq)-1;

hh=diff(tau)./(q(2)-q(1));
Dh=(q(1:(end-1)).*hh)-tau(1:(end-1));
h=hh-1;

         