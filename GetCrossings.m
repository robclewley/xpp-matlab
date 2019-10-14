function crossings = GetCrossings(data,threshold,maxcrossings,dirn,indices,verboseTog)
%GetCrossings  Convert simulation output data into threshold crossing times
%  (c) Rob Clewley, 2004
%  GetCrossings(data,threshold,maxcrossings,dirn) takes an array of data with time in
%  the first column, variables in remaining columns, and a threshold crossing value. This
%  function detects threshold crossings in the direction given by dirn in all variables.
%  Use dirn = -1 for decreasing threshold crossings, 1 for increasing threshold crossings.
%  Use dirn = 0 for detection of all threshold crossings, in either direction.
%  Linear interpolation is used to find the crossing times accurately.  The optional 5th
%  argument indices is a list of indices to select from the variable columns (when there
%  are mixture of spiking and non-spiking variables present in the passed data set). If it
%  is omitted, all the variable columns are searched.
%
%  The result is an array, crossings, having dimensions |indices| by maxcrossings. In each
%  of the rows are the crossing times of each variable in the passed data set. maxcrossings
%  is set to 100 by default if it is omitted. However, if maxcrossings is set at 0, the
%  function returns a cell array of crossing time cell arrays, with rows of length equal to
%  the number of crossings in the data.
%
%  The final, optional, boolean argument verboseTog controls suppression of warning
%  messages (defaults to false).

switch nargin
    case 6
    case 5
        verboseTog = false;
    case 4
        verboseTog = false;
        indices = 2:length(data(1,:));
    case 3
        verboseTog = false;
        indices = 2:length(data(1,:));
        dirn = 0;
    case 2
        verboseTog = false;
        indices = 2:length(data(1,:));
        dirn = 0;
        maxcrossings = 100;
    otherwise
        disp(' GetCrossings: Wrong number of arguments passed')
        return
end

if ismember(1,indices)
    disp(' GetCrossings: First element of data should not be in indices list.')
    return
end

% if [] is passed for indices, use all variable (non-time) indices
if isempty(indices)
    indices = 2:length(data(1,:));
end

numvars = length(indices);
numtimes = length(data(:,1));

if numvars == 0 | numtimes < 2
    disp(' GetCrossings: Too few variables or too few data-points passed')
    crossings = [];
    return
end

if maxcrossings > 0
    crossings = zeros(numvars,maxcrossings);
else
    crossings = cell(numvars,1);
    for i=1:numvars
        crossings{i} = {}; % initialize cell arrays
    end
end
maxedout = zeros(numvars);
numcrossings = zeros(numvars);

% don't start at t=1 because need a prior data point to detect threshold crossing
if dirn ~= 0
    dirn_itlist = dirn;
else
    dirn_itlist = [-1, 1];
end
if maxcrossings > 0 % return a regular array of fixed size
	for t=2:numtimes
        for v=1:numvars
            data_ix = indices(v);
            for dirn_it = dirn_itlist
                if dirn_it*data(t-1,data_ix) < dirn_it*threshold & dirn_it*data(t,data_ix) >= dirn_it*threshold
                    if numcrossings(v) < maxcrossings
                        numcrossings(v) = numcrossings(v)+1;
                        if dirn_it*data(t,data_ix) > dirn_it*threshold
                            crossings(v,numcrossings(v)) = LinearInterpolateData(data(t-1,data_ix),threshold,data(t,data_ix),data(t-1,1),data(t,1));
                        else % equal to threshold
                            crossings(v,numcrossings(v)) = data(t,1);
                        end
                    else
                        maxedout(v) = 1;
                    end
                end
            end
        end
	end
    if sum(maxedout)>0 & verboseTog
        disp(' GetCrossings: At least one variable maxed out its specified maximum number of recordable crossings.')
    end
else % return a cell array
    for t=2:numtimes
        for v=1:numvars
            data_ix = indices(v);
            for dirn_it = dirn_itlist
                if dirn_it*data(t-1,data_ix) < dirn_it*threshold & dirn_it*data(t,data_ix) >= dirn_it*threshold
                    numcrossings(v) = numcrossings(v)+1;
                    if dirn_it*data(t,data_ix) > dirn_it*threshold
                        crossings{v} = {crossings{v}{:}, LinearInterpolateData(data(t-1,data_ix),threshold,data(t,data_ix),data(t-1,1),data(t,1))};
                    else % equal to threshold
                        crossings{v} = {crossings{v}{:}, data(t,1)};
                    end
                end
            end
        end
	end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function interpolatedx = LinearInterpolateData(x0,xthresh,x1,t0,t1)
interpolatedx = ( t1 * (xthresh - x0) + t0 * ( x1 - xthresh) ) / (x1-x0);