function [ F ] = genmfunfriction( CGen )
%% GENMFUNFRICTION Generates M-functions from the symbolic robot specific friction model.
%
%  [] = genmfunfriction(cGen)
%  [] = cGen.genmfunfriction
%
%  Inputs::
%       cGen:  a CodeGenerator class object
%
%       If cGen has the active flag:
%           - saveresult: the symbolic expressions are saved to
%           disk in the directory specified by cGen.sympath
%
%           - genmfun: ready to use m-functions are generated and
%           provided via a subclass of SerialLink stored in cGen.robjpath
%
%           - genslblock: a Simulink block is generated and stored in a
%           robot specific block library cGen.slib in the directory
%           cGen.basepath
%
%  Authors::
%        J�rn Malzahn
%        2012 RST, Technische Universit�t Dortmund, Germany
%        http://www.rst.e-technik.tu-dortmund.de
%
%  See also CodeGenerator, gengravload

% Copyright (C) 1993-2012, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
%
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com 

%% Does robot class exist?
if ~exist(fullfile(CGen.robjpath,CGen.getrobfname),'file')
    CGen.logmsg([datestr(now),'\tCreating ',CGen.getrobfname,' m-constructor ']);
    CGen.createmconstructor;
    CGen.logmsg('\t%s\n',' done!');
end

%% Generate m-function
CGen.logmsg([datestr(now),'\tGenerating joint friction m-function']);
symname = 'friction';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    tmpStruct = load(fname);
else
    error ('genmfunfriction:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.m']);
[~,qd] = CGen.rob.gencoords;

matlabFunction(tmpStruct.(symname),'file',funfilename,...              % generate function m-file
    'outputs', {'F'},...
    'vars', {'rob',[qd]});
hStruct = createHeaderStruct(CGen.rob,symname);                 % replace autogenerated function header
replaceheader(CGen,hStruct,funfilename);
CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStruct(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Joint friction for the ',rob.name,' arm.'];
hStruct.calls = {['F = ',hStruct.funName,'(rob,qd)'],...
    ['F = rob.',hStruct.funName,'(qd)']};
hStruct.detailedDescription = {['Given a full set of generalized joint velocities the function'],...
    'computes the friction forces/torques.'};
hStruct.inputs = { ['rob: robot object of ', rob.name, ' specific class'],...
                   ['qd:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     velocities', ...
                   'Angles have to be given in radians!'};
hStruct.outputs = {['F:  [',int2str(rob.n),'x1] vector of joint friction forces/torques']};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'J�rn Malzahn',...
    '2012 RST, Technische Universit�t Dortmund, Germany',...
     'http://www.rst.e-technik.tu-dortmund.de'};
hStruct.seeAlso = {'gravload'};
end
