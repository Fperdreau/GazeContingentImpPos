function fitparam = GetFitParam(param,const)

if const.blocType ~= param.blocType
    const.blocType = param.blocType;
end

%% Window size
if const.blocType == 1
    apert = const.Exp.apertType1;
    WinX = pi.*(const.Exp.VAapertType1./2).^2;
    WinX(9) = (21^2);
    WinX = roundn(WinX,0);
else
    apert = rot90(const.Exp.apertType2,2);
    apert = [apert(2:9) max(apert)];
    WinX = ((21^2)-(pi.*(const.Exp.VAapertType2./2).^2));
    WinX = [WinX(8:-1:1), (21)^2];
    WinX = roundn(WinX,0);
end

fitparam.apert = apert;
fitparam.WinX = log(WinX);

end
