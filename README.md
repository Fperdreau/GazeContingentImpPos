# The artists advantage: Better integration of object information across eye movements

Author: Florian Perdreau (fp@florianperdreau.fr)
Year: 2012
Version: 1.0.0

## DESCRIPTION
This repository provides the experiment and data analysis code of the paper Perdreau & Cavanagh (2013a).

This study investigated whether drawing expertise would be related to a more 
stable memory representation of an object structure progressively built up 
from either foveal or peripheral visual information sampled across 
eye-movements.

## REFERENCE
Perdreau, F., & Cavanagh, P. (2013). The artist’s advantage: Better 
integration of object information across eye movements. I-Perception, 
4(6), 380–395. http://doi.org/10.1068/i0574

## LICENSE:
Copyright (C) 2012 Florian Perdreau, University Paris Descartes

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## METHOD
### APPARATUS
* Eye-tracker: SR Research Eyelink 1000, 35mm binocular lens

### PROCEDURE
List of conditions:

* Object selection: the aim of this experiment is to select structurally 
possible and impossible objects with a high intra-rater agreement (measured
by Cronbach's alpha). Participants of this experiment did not take part in 
the main experiments.

* Drawing task: participant has to copy as accurately as possible a
model picture displayed on a computer screen within a limited time.

* Pre-test: Pre-selected objects are presented to the participant
and his task is to judge whether the object is structurally
possible or impossible. Objects are fully visible during this
condition.

* Gaze-contingent experiment: during this experiment, line-drawings
of objects are presented on a computer screen and participant has to 
decide whether the object is structurally possible or impossible. 
However, the object is only partially visible: a gaze-contingent 
window either blocks central or peripheral visual information.

## MANUAL
### Experiment
The full set of experiment conditions can be run by simply calling runExp.m
function. 

A simpler demo version of the gaze-contingent experiment can be 
executed by calling runDemo.m function.

### Data analysis
Data analyses can be performed by calling analyses.m script. If provided, 
behavioral and eye-movement data should be stored in /Data/Subjects folder.
