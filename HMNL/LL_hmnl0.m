function f = LL_hmnl0(Xmea,EstimOpt,b)

% save tmp_LL_hmnl0
% return

l = 0;
L_mea = ones(EstimOpt.NP,1);
for i = 1:size(Xmea,2)
    if EstimOpt.MeaSpecMatrix(i) == 0 % OLS
        X = ones(EstimOpt.NP,1);
        bx = b(l+1:l+2);
        X_mea_n = Xmea(:,i);
        L = normpdf(X_mea_n,X*bx(1),exp(bx(2)));
        L_mea = L_mea.*L;
        l = l+2;
    elseif EstimOpt.MeaSpecMatrix(i) == 1 % MNL 
        UniqueMea = unique(Xmea(:,i)); 
        k = length(UniqueMea)-1;
        bx = [0,b(l+1:l+k)'];
        l = l + k; 
        V = exp(ones(EstimOpt.NP,1)*bx); %NP x Unique values
        Vsum = sum(V,2); 
        V = V./Vsum(:,ones(1,k+1));
        L = zeros(EstimOpt.NP,1);
        for j = 1:length(UniqueMea)
            L(Xmea(:,i) == UniqueMea(j)) = V(Xmea(:,i) == UniqueMea(j),j);
        end
        L_mea = L_mea.*L;        
    elseif EstimOpt.MeaSpecMatrix(i) == 2 % Ordered Probit
       UniqueMea = unique(Xmea(:,i)); 
       k = length(UniqueMea)-1;
       bx= b(l+1:l+k);
       bx(2:end) = exp(bx(2:end));
       bx = cumsum(bx);
       L = zeros(EstimOpt.NP,1);
       L(Xmea(:,i) == min(UniqueMea)) = normcdf(bx(1));
       L(Xmea(:,i) == max(UniqueMea)) = 1-normcdf(bx(end));
       for j = 2:k
           L(Xmea(:,i) == UniqueMea(j)) = normcdf(bx(j)) - normcdf(bx(j-1));
       end
       %L = reshape(L, EstimOpt.NRep, EstimOpt.NP);
       L_mea = L_mea.*L;
       l = l+k;
    end
end
f = -sum(log(max(L_mea,realmin)));
