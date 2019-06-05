function options = parseOptions(varargin)
IP = inputParser;
IP.addParamValue('mode', 'binary', @ischar)
IP.addParamValue('title', sprintf('Created by stlwrite.m %s',datestr(now)), @ischar);
IP.addParamValue('triangulation', 'f', @ischar);
IP.addParamValue('facecolor',[], @isnumeric)
IP.addParamValue('facecolour',[], @isnumeric)
IP.parse(varargin{:});
options = IP.Results;
if ~isempty(options.facecolour)
    options.facecolor = options.facecolour;
end
end