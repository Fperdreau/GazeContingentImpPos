function r = intracorr(X)

N = size(X,1);
K = size(X,2);

new = reshape(X,1,prod(size(X)));
%%
for i = 1:N
    score(i,:) = (mean(X(i,:)) - mean(new)).^2;
end
s = std(new);
vaR = ((1/N)*sum(score))/(s^2);
r = (K/(K-1))*(vaR) - (1/(K-1));

end