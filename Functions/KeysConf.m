function Keys = KeysConf

%% Keys setting
Keys.StopAll = KbName('ESCAPE');
Keys.Practice = [KbName('y'), KbName('n')];
Keys.response = [KbName('s'), KbName('l')]; %Impossible, Possible
Keys.calib = [KbName('c'), KbName('v'), KbName('RETURN'), KbName('Space')];
Keys.navig = [KbName('Leftarrow'), KbName('Rightarrow')];
RestrictKeysForKbCheck([Keys.StopAll, Keys.response, Keys.calib, Keys.Practice, Keys.navig]);

end