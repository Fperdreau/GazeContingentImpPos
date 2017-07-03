function const = EyExpconf(p, const)

const.Exp.distance = 560;
const.Exp.level = .95;
const.Exp.minthresh = .80;
const.Exp.VAmax = 21;
[w h] = VistoPix(const.Exp.VAmax,1, p.screenNum, const.Exp.distance, p);
const.Exp.VA = [w h];
const.Exp.SD = 2; % SD of mask blob
const.Exp.calTargetRadVal = VistoPix(1, 1, p.screenNum, const.Exp.distance, p);
const.Exp.calTargetWidthVal = VistoPix(0.5, 1, p.screenNum, const.Exp.distance, p);
const.Exp.imBackcolor = 200;
const.Exp.ifi = 1/p.flipInt;
const.Exp.fixationDuration = 1; % duration of fixation test (in seconds)
const.Exp.timefix = .250; % fixation time (in seconds)
const.Exp.trialDuration = 10; % duration of a trial (in seconds)

const.Exp.VAapertType1 = linspace(2, const.Exp.VAmax/2,9); % range from fovea, fovea+parafovea, periphery
const.Exp.VAapertType2 = linspace(10, const.Exp.VAmax,9); % range from fovea, fovea+parafovea, periphery
const.Exp.apertType1 = VistoPix(const.Exp.VAapertType1, 1, p.screenNum, const.Exp.distance, p);
const.Exp.apertType2 = VistoPix(const.Exp.VAapertType2, 1, p.screenNum, const.Exp.distance, p);


end

