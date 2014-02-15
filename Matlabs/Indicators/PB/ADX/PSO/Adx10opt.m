function [ rec, calmarb, paropt, sumrec, ldopt] = Adx10opt( C, spread, pocz, kon, P1, P2, P3, P4, P5StopLoss)

calmarb = -Inf;
rec = -Inf;
liczba = length(P1);
licznik = 1;

for p1=P1
%    fprintf('Wykonano: %.3f procent\n', 100*(licznik-1)/liczba);
    for p2=P2(1):p1/2
        for p3=P3
            for p4=P4
				for p5StopLoss=P5StopLoss
					[ zysk, Calmar, sumz, LongShort ] = Adx10fun(C, spread, pocz, kon, p1, p2, p3, p4, p5StopLoss);
					if zysk>rec
%					if Calmar>calmarb
						rec=zysk;
						calmarb = Calmar;
						paropt=[p1 p2 p3 p4];
						sumrec=sumz;
						ldopt=LongShort;
					end
				end
            end %p1
        end  %p2
    end %p3
    licznik = licznik+1;
end%p4


end

