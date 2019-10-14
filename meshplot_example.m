%  3D mesh plot example script for XPP batch running from Matlab.
%  Uses a Hodgkin-Huxley model neuron, and varies two parameters
%  plotting frequency on the Z-axis.
%  Rob Clewley, August 2004

disp('Multi-parameter variation in XPP from Matlab, with spike-time post-processing')
disp(' ')
disp('This is an example of varying current drive `i` and slow sodium maximum conductance')
disp('  `g_p` in a Hodgkin-Huxley model, to demonstrate the functions that determine spike')
disp('  times from the output data files, and generate a 3D mesh plot showing the spiking')
disp('  frequency of these as the two parameters vary.')

% user specifications
odeFileName = 'HH_slowNa.ode';
irange = -1.00:0.5:4.50;
grange = 0:0.2:1.5;
verboseTog = false; % two levels of notification verbosity to user

% initializations
i_ix = 0;
g_ix = 0;
leni = length(irange);
leng = length(grange);
Z = zeros(leni,leng);
X = grange;
Y = irange;
ilen = length(irange);
glen = length(grange);
numpoints = ilen * glen;

fprintf('Calculating %d points\n',numpoints)
pointnum = 0;
count = 0; % line print count, for backspacing purposes
INFINITY = 300; % upper bound for our purposes
maxZ = 0;
minZ = INFINITY;

newpars(1).name='i';
newpars(1).type='PAR';
newpars(2).name='g_p';
newpars(2).type='PAR';

for i=irange
    i_ix = i_ix+1;
    g_ix = 0;
    for g = grange
        g_ix = g_ix+1;
        pointnum = pointnum + 1;
        if ~verboseTog % then print current loop counter
            bspstr = '';
            if count > 0
                for bix=1:count
                    bspstr = [bspstr '\b']; 
                end
            end
            fprintf(bspstr);
            count = fprintf('%d',pointnum);
        end
        newpars(1).val = i;
        newpars(2).val = g;
        if verboseTog
            fprintf(' **** Point %d: Variable pt = %.4f, c = %.4f\n',pointnum,newpars(1).val,newpars(2).val)
        end
		success = ChangeXPPodeFile(odeFileName,newpars); % type `help ChangeXPPodeFile` in Matlab
        if success==0
            disp('Change XPP ode file failed')
            return
        end
		success = RunXPP(odeFileName); % type `help RunXPP` in Matlab
        if success==0
            disp('Run XPP failed')
            return
        end
        data = load('output.dat'); % change this if your ODE file explicitly names a data file
        spikedata=GetCrossings(data,0,10,1,2,false); % type `help GetCrossings` in Matlab
        if spikedata(1) > 0
            numspikes = length(find(spikedata(:)>0));
            isi=0;
            if numspikes == 1
                freq=0;
            else
                for sp=2:numspikes
                    isi = isi + spikedata(sp)-spikedata(sp-1);
                end
                freq = 1000*(numspikes-1)/isi;
            end
            Z(i_ix,g_ix) = freq;
            maxZ = max(maxZ,Z(i_ix,g_ix));
            minZ = min(minZ,Z(i_ix,g_ix));
        else % no spike-time found
            Z(i_ix,g_ix) = 0;
        end
        if verboseTog
            fprintf(' spike time found at = %.4f\n', Z(i_ix,g_ix))
        end
    end
end
fprintf('\n')
beep

save figsave.mat X Y Z
fprintf('Saved X Y Z data to file `figsave.mat`\n')

fighandle=figure;
mesh(X,Y,Z)
axis([ grange(1) grange(leng) irange(1) irange(leni) minZ maxZ])
return