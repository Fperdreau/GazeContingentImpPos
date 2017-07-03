function practice = PracticeDesign(const,test)

% Make Practice design
practice.ncat = 2;
practice.nimg = 2;
practice.ntri = 4;
practice.nwindow = 1;
practice.design = fullfact([practice.ntri practice.ncat practice.nwindow]); % factorial experimental plan
practice.ntesttrials = size(practice.design);
practice.ntesttrials = practice.ntesttrials(1); % Number of test trials
practice.design(practice.design(:,3) == 1,3) = const.Exp.apert(4);

% Set images order
practice.design(practice.design(:,2) == 1,4) = test.imp(randi(size(test.imp,2),1,practice.ntesttrials/2));
practice.design(practice.design(:,2) == 2,4) = test.poss(randi(size(test.poss,2),1,practice.ntesttrials/2));

% Set orientations order
practice.design(practice.design(:,2) == 1,5) = randi(test.nori,1,practice.ntesttrials/2);
practice.design(practice.design(:,2) == 2,5) = randi(test.nori,1,practice.ntesttrials/2);

% Randomize trials order
practice.design = practice.design(randperm(length(practice.design(:,1))),:); % randomize trials order

end