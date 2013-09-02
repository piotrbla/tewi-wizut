function [macdval signal] = macd(data,p1,p2,p3)

% calculate the MACD
macdval = ema(data,p2)-ema(data,p1);

% Need to be careful with handling NaN's in the second calculation
idx = isnan(macdval);
signal = [macdval(idx); ema(macdval(~idx),p3)];
