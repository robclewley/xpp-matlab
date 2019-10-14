function success = RunXPP(odeFilename, setFilename, newseed, xppname)
%RunXPP  Run XPP in silent mode
%  (c) Robert Clewley, 2004
%  RunXPP(odeFilename, setFilename, newseed, xppname) runs the XPP executable that is assumed to be in
%  the local directory on the ODE file odeFilename (having extension '.ode'). The optional string
%  argument setFilename can be set to the name of a set file which will be used by the silent runs of
%  XPP. The optional boolean argument newseed (default is false) that signals XPP to re-seed its
%  random number generator, for instance when running simulations involving random variables. The
%  final, optional, argument xppname additionally specifies the name of the XPP executable file if the
%  default name assumed by RunXPP is not correct.

success = false; % off to an optimistic start
switch nargin
    case 4
    case 3
        xppname = '';
    case 2
        xppname = '';
        newseed = false;
    case 1
        xppname = '';
        newseed = false;
        setFilename = '';
    otherwise
        disp('RunXPP: Wrong number of arguments passed')
end

cstr = computer;
if strcmp(cstr, 'MAC')
    compix = 0;
elseif strcmp(cstr, 'PCWIN')
    compix = 1;
else % assume UNIX etc. (no-one uses VMS any more)
    compix = 2;
end

if isempty(odeFilename) || ~exist(odeFilename)
    disp(' ODE file specified is not present in working directory')
    return
end
if ~strcmp(EndRemainStr(odeFilename,'.'),'ode')
    disp(' Must specify a filename with extension `.ode`')
    return
end

if isempty(setFilename)
    setfile_str = '';
else
    if ~exist(setFilename)
        disp(' SET file not present in working directory')
        return
    end
    setfile_str = [' -setfile ' setFilename ' '];
end
if newseed
    newseed_str = ' -newseed ';
else
    newseed_str = '';
end

switch compix
    case 0
        if isempty(xppname)
            try eval(['!xppaut -silent ' setfile_str newseed_str odeFilename],'disp('' Call to XPP failed'')'), catch disp(' Call to XPP failed'), return, end;
        else
            try eval(['!' xppname ' -silent ' setfile_str newseed_str odeFilename],'disp('' Call to XPP failed'')'), catch disp(' Call to XPP failed'), return, end;
        end
    case 1
        if isempty(xppname)
            [s w] = dos(['xppaut -silent ' setfile_str newseed_str odeFilename]);
            if s % then failed
                disp(' Call to XPP failed')
                return
            end
        else
            [s w] = dos([xppname ' -silent ' setfile_str newseed_str odeFilename]);
            if s % then failed
                disp(' Call to XPP failed')
                return
            end
        end
    case 2
        if isempty(xppname)
            [s w] = unix(['xpp ' odeFilename ' -silent' setfile_str newseed_str]);
			if s % then failed
                disp(' Call to XPP failed')
                return
			end
        else
            [s w] = unix([xppname ' ' odeFilename ' -silent' setfile_str newseed_str]);
            if s % then failed
                disp(' Call to XPP failed')
                return
            end        
        end
end
success = true; % if we got this far
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this function returns the remainder (e.g. the extension) of a string, without the delimiter findChar 
function stripStr = EndRemainStr(inputStr,findChar,lastDelim)
if nargin==2
    lastDelim = false;
end
ix = findstr(findChar,inputStr);
if ~isempty(ix)
    if lastDelim
        if max(ix)>1
            stripStr = inputStr(max(ix)+1:length(inputStr));
        else
            stripStr = [];
        end
    else
        if min(ix)>=1
            stripStr = inputStr(min(ix)+1:length(inputStr));
        else
            stripStr = [];
        end
    end
else
    stripStr = [];
end
return
