function crnt_scope( )
%CRNT_SCOPE
%   Simple scope for the Context Recognition Network Toolbox (CRNT).
%   Connects to an IP socket via Peter Rydesäter's pnet toolbox
%   to scope the data streamed over TCP/IP.
%
%   'freeze' Halts the plot figure, while the data is aquired in the
%            background.
%   'copy'   Copies the the last 1000 aquired data samples to the
%            clipboard.
%   Quit the program by closing the control window.
% 
%   'channels' should be either defined as a matlab vector (the given
%   channels are displayed in a single plot) or as a matlab cell array of
%   vectors (each vector defines the channels for each subplot).
%   * An empty cell array '<a href="matlab:{}">{}</a>' (default value) will
%     plot each channel in a separate subplot.
%   * An empty matrix '<a href="matlab:[]">[]</a>' will plot all channels
%     in a single subplot. 
%   * example: sending the MTx calibrated data using the
%              TimestampedLinesEncoder the following string will group both
%              acceleration and gyroscope data into one subplot each:
%                 <a href="matlab:{[3:5],[6:8]}">{[3:5],[6:8]}</a>
%              (channels 1 and 2 belong to the timestamp)
%
%   In 'spectrum'-mode a vector must be given in field channels, e.g.,
%   2:12 or 12 or [2,5:12]
%
%   requirements:
%   - TCP/UDP/IP Toolbox 2.0.5
%   - MATLAB 7.0
%
%   How to get Peter Rydesäter's TCP/UDP/IP Toolbox 2.0.5
%   - Download it from, e.g.,
%         http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=345
%   - Extract the files to any directory.
%   - Assuming that you extracted it to 'c:\pnet' type addpath('c:\pnet')
%   - compile the pnet toolbox, for more information
%     see '<a href="matlab:edit pnet.c">pnet.c</a>'
% 
%   Known issues:
%   - pnet will compile but not work on Intel Macs (due to some Matlab bug
%     there).
% 
% Copyright (C) 2007 David Bannach, Embedded Systems Lab
% 
% This file is part of the CRN Toolbox.
% The CRN Toolbox is free software; you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published
% by the Free Software Foundation; either version 2.1 of the License, or
% (at your option) any later version.
% The CRN Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU Lesser General Public License for more details.
% You should have received a copy of the GNU Lesser General Public License
% along with the CRN Toolbox; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
% 

cur_ver = 0.4 ;
%% change history
% 22.10.2007
% - event display mode available (initial release)
% 
% 06.07.2007
% - grouping of channels
% - number of displayed samples can be changed via gui
% - scope or roll mode
%
% 21.09.2005
% - introduced nested functions (=> needs Matlab 7.0 or higher), some 6.5
%   programming style is still remaining
% - copy to clipboard available
% - freeze mode available
% - some bug fixes
% - some gui modifications
% - matlab does not chrash in case remote host closes connection
% - added some help text
%
% fall, 2004
% - initial version
%
%% todo
% - make 2nd display mode available via gui
% - make event display options available via gui
% - make event display available in 2nd display mode
% - command line interface
% - update help text
% 
%% contact
% georg.ogris@fim.uni-passau.de

%% currently the params for the event display have to be changed here:
PORT2 = 7778 ;   % the port number
MAX_EVENTS_DISPLAYED = 9 ; % the maximum number of events displayed per subfigure
% eof EVENT DISPLAY OPTIONS

disp(['CSN:::TB_SCOPE v',num2str(cur_ver)])

helptxt = help(mfilename) ;

if exist('pnet','file') ~= 3
    disp('Peter Rydesäter''s TCP/UDP/IP Toolbox is not installed properly.')
    disp(['Type ','<a href="matlab:help crnt_scope">help ',...
        mfilename,'</a> for more information.'])
    return
end
if str2double( version('-release') ) < 14
    error('''crnt_scope'' requires MATLAB 7 or higher') ;
end

%% control inits
bFrozen = false ;
bConnected = false ;

%% gui control inits
scrsz = get(0,'ScreenSize') ;
buttonPos = [10 10] ;
buttonSiz = [60 20] ;
ctr_fig_s = buttonSiz(1)*4+buttonPos(1)*5-1 ;
ctr_fig_l = buttonSiz(1)*7.5+buttonPos(1)*5 ;

%% buffer inits
bufferSize = 1000 ;
dataBuffer = [] ;
ylimits = [] ;

%% plot inits
bSpectrum = false ;
plotIndices = [] ;
current_dimension = [] ;
numPlotFigures = [] ;
maxChannelRequest = [] ;
bXRoll = true ;

%%  gui inits
FIG_HANDLE = figure('Position',[10 40 ctr_fig_s ...
    buttonSiz(2)*3+buttonPos(2)*4],...
    'Name','esl:::crnt_scope:::control', 'NumberTitle','off', ...
    'Visible','off', 'BackingStore','off', 'MenuBar','none', ...
    'Resize','off', 'CloseRequestFcn', @closeFigs ) ;
PLOTFIG_HANDLE = figure('Position', [scrsz(3)*0.05 scrsz(4)*0.1 scrsz(3)*0.8 scrsz(4)*0.8],...
    'Name','esl:::crnt_scope:::plot', 'NumberTitle','off', ...
    'Visible','off', 'BackingStore','off', ...
    'DoubleBuffer', 'on', ...
    'CloseRequestFcn', @close_plot) ;
figure(FIG_HANDLE) ;

MSG_HANDLE = uicontrol( 'style','text', ...
    'position',[buttonPos(1) buttonPos(2)*3.5+buttonSiz(2)*2 ...
    buttonSiz(1)*4+buttonPos(2)*3 buttonSiz(2)], ...
    'BackgroundColor',[0.8 0.8 0.8], 'FontSize',11, ...
    'FontWeight','bold', 'FontName','FixedWidth', ...
    'string','http://esl.fim.uni-passau.de/');

CONNECT_HANDLE = uicontrol( 'string','connect', ...
    'position', [buttonPos buttonSiz], ...
    'callback', @tb_connect, 'interruptible','on' ) ;
DISCONNECT_HANDLE = uicontrol( 'string','disconnect', ...
    'position', [buttonPos buttonSiz], ...
    'callback', @disconnect, 'interruptible','off', 'visible','off') ;
FREEZE_HANDLE = uicontrol( 'string','freeze',  ...
    'position',[buttonPos(1)*2+buttonSiz(1)*1 buttonPos(2) buttonSiz], ...
    'callback', @freeze, 'enable','off' ) ;
uicontrol( 'string','copy', ...
    'position',[buttonPos(1)*3+buttonSiz(1)*2 buttonPos(2) buttonSiz], ...
    'callback', @copy2clip, 'interruptible','off' );
MORE_HANDLE = uicontrol( 'string','more >>', ...
    'position',[buttonPos(1)*4+buttonSiz(1)*3 buttonPos(2) buttonSiz], ...
    'callback', @switch_gui_size ) ;
uicontrol( 'string','help', ...
    'position',[buttonPos(1)*7+buttonSiz(1)*6 buttonPos(2) buttonSiz], ...
    'callback', @disp_help ) ;

B_SPECTRUM_TEXT_HANDLE = uicontrol( 'style','text','FontSize',8,'string','spectrum', ...
    'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
    'position',[buttonPos(1)*4+buttonSiz(1)*3 buttonPos(2)*3.3+buttonSiz(2)*1 buttonSiz] ) ;
B_SPECTRUM_HANDLE = uicontrol( 'style','checkbox','string','', 'BackgroundColor',[0.8 0.8 0.8], ...
    'position',[buttonPos(1)*4+buttonSiz(1)*3 buttonPos(2)*2+buttonSiz(2)*1 buttonSiz], ...
    'callback', @change_view, 'FontSize',7 );

CHANNEL_TEXT_HANDLE = uicontrol( 'style','text','FontSize',8,'string','channels', ...
    'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
    'position',[buttonPos(1)*5+buttonSiz(1)*4 buttonPos(2)*3.3+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;
CHANNEL_HANDLE = uicontrol( 'style','edit','string','{}', 'BackgroundColor',[1.0 1.0 1.0], ...
    'position',[buttonPos(1)*5+buttonSiz(1)*4 buttonPos(2)*2+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] );
uicontrol( 'string','channels?', ...
    'position',[buttonPos(1)*5+buttonSiz(1)*4 buttonPos(2) buttonSiz], ...
    'callback', @disp_channels ) ;

uicontrol( 'style','text','FontSize',8,'string','samples', ...
    'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
    'position',[buttonPos(1)*7+buttonSiz(1)*6 buttonPos(2)*3.3+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;
TBASE_HANDLE = uicontrol( 'style','edit','string',num2str(bufferSize), 'BackgroundColor',[1.0 1.0 1.0], ...
    'position',[buttonPos(1)*7+buttonSiz(1)*6 buttonPos(2)*2+buttonSiz(2) buttonSiz] );

B_XSCROLL_MODE_HANDLE = uicontrol( 'string','scope', ...
    'position',[buttonPos(1)*6+buttonSiz(1)*5 buttonPos(2) buttonSiz], ...
    'callback', @toggle_xscroll_mode ) ;

uicontrol( 'style','text','FontSize',8,'string','Port', ...
    'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
    'position',[buttonPos(1) buttonPos(2)*3.3+buttonSiz(2) buttonSiz] ) ;
PORT_HANDLE = uicontrol( 'style','edit', 'string','7777', 'BackgroundColor',[1 1 1], ...
    'position',[buttonPos(1) buttonPos(2)*2+buttonSiz(2) buttonSiz] ) ;
uicontrol( 'style','text','FontSize',8,'string','IP address', ...
    'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
    'position',[buttonPos(1)*2+buttonSiz(1) buttonPos(2)*3.3+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;
ADDRESS_HANDLE = uicontrol( 'style','edit', 'string','localhost', 'BackgroundColor',[1 1 1], ...
    'position',[buttonPos(1)*2+buttonSiz(1) buttonPos(2)*2+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;

%%  nested function tb_connect
    function tb_connect(h,eventdata)
        clf(PLOTFIG_HANDLE) ;
        set(PLOTFIG_HANDLE,'visible','on') ;
        set(CONNECT_HANDLE,'visible','off') ;
        set(DISCONNECT_HANDLE,'visible','on') ;
        set(FREEZE_HANDLE,'enable','on') ;
        set(PORT_HANDLE,'enable','off');
        set(ADDRESS_HANDLE,'enable','off');
        set(B_SPECTRUM_HANDLE,'enable','off');
        set(B_SPECTRUM_TEXT_HANDLE,'enable','off');
        set(CHANNEL_HANDLE,'enable','off');
        set(CHANNEL_TEXT_HANDLE,'enable','off');
        set(B_XSCROLL_MODE_HANDLE,'enable','off');
        set(TBASE_HANDLE,'enable','off');

        figure(PLOTFIG_HANDLE) ;
        
        if ~init_plot_indices() || ~init_tbase()
            close_plot() ;
            return
        end

        IP_ADDRESS = get(ADDRESS_HANDLE,'string');
        PORT = get(PORT_HANDLE,'string');
        set(MSG_HANDLE,'string','connecting ...');
        IP_STRING = IP_ADDRESS;
        bEvents = false ;
        TCP_EVENT_SERVER = pnet('tcpconnect',IP_STRING,PORT2) ;
        if TCP_EVENT_SERVER >= 0
            bEvents = true ;
        end
        TCP_SERVER = pnet('tcpconnect',IP_STRING,PORT) ;
        if TCP_SERVER >= 0
            bConnected = true;
            set(MSG_HANDLE,'string',['connected to ',IP_STRING]);
            
            if bSpectrum
                if iscell(plotIndices)
                    close_plot() ;
                    warning('TB_SCOPE:WrongIdxFormat',...
                        'In spectrum view value for index must be a vector.') ;
                    return
                end
                DIM = 0;
                while DIM == 0
                    data = str2num(pnet(TCP_SERVER,'read','noblock'));
                    DIM = size(data,2);
                    current_dimension = DIM ;
                end
                if isempty(plotIndices)
                    plotIndices = 1:DIM ;
                    maxChannelRequest = DIM ;
                end
                if maxChannelRequest > DIM
                    close_plot() ;
                    warning('TB_SCOPE:IndexOutOfRange',...
                        'One or more requested channels do not exist.') ;
                    return
                end
                PLOT_HANDLES = bar(data(end,plotIndices));
                shandle = gca;
                set(shandle, 'XGrid','on','YGrid','on' );
                
            else
                % get number of subplots
                DIM = 0;
                while DIM == 0
                    data = str2num(pnet(TCP_SERVER,'readline'));
                    DIM = size(data,2);
                    current_dimension = DIM ;
                end
                if isempty(plotIndices) && ~iscell(plotIndices)
                    plotIndices = 1:DIM ;
                    maxChannelRequest = DIM ;
                elseif isempty(plotIndices) && iscell(plotIndices)
                    plotIndices = cell(1,DIM) ;
                    for iP = 1:DIM
                        plotIndices{iP} = iP ; 
                        maxChannelRequest = DIM ;
                    end
                end
                if maxChannelRequest > DIM
                    close_plot() ;
                    warning('TB_SCOPE:IndexOutOfRange',...
                        'One or more requested channels do not exist.') ;
                    return
                end
                if ~iscell(plotIndices)
                    plotIndices = {plotIndices} ;
                end
                numPlotFigures = numel(plotIndices) ;
                
                % init data buffer
                dataBuffer = zeros(bufferSize,DIM);
                altDataBuffer = zeros(bufferSize,DIM);
                altDataBufferIdx = 1 ;
                for iP = 1:DIM
                    dataBuffer(:,iP) = dataBuffer(:,iP) + data(iP);
                end
                
                % init plots
                xnsp = ceil(sqrt(numPlotFigures));
                ynsp = ceil(numPlotFigures/xnsp);
                if bEvents
                    eventBuffers = cell(numPlotFigures,1) ;
                    eventObjHandles = zeros(numPlotFigures,MAX_EVENTS_DISPLAYED) ;
                end
                shandle = zeros(numPlotFigures,1) ;
                PLOT_HANDLES = cell(numPlotFigures,1) ;
                for iP = 1:numPlotFigures
                    shandle(iP) = subplot(xnsp,ynsp,iP);
                    if bEvents
                        eventBuffers{iP} = zeros(MAX_EVENTS_DISPLAYED,5) ;
                        for iME = 1:MAX_EVENTS_DISPLAYED
                            eventObjHandles(iP,iME) = initFillObj() ;
                            hold on
                        end
                    end
                    PLOT_HANDLES{iP} = ...
                        plot( 1 : bufferSize, ...
                            dataBuffer(:,plotIndices{iP}) );
                    set(shandle(iP), 'XGrid','on','YGrid','on' );
                    if ~isempty(ylimits)
                        ylim(ylimits) ;
                    end
                end
            end

            while bConnected
                try
                    data = str2num(pnet(TCP_SERVER,'read','noblock'));
                catch
                end
                [nData,nDim] = size(data);
                if nData > bufferSize
                    data = data(end-bufferSize+1:end,:) ;
                    nData = bufferSize ;
                end
                if bSpectrum && nData > 0 && nDim == DIM && ~bFrozen
                    set(PLOT_HANDLES,'YData',data(end,plotIndices));
                elseif nData > 0 && nDim == DIM
                    dataBuffer = circshift(dataBuffer,[-nData 0]);
                    dataBuffer(end-nData+1:end,:) = data;
                    if bEvents
                        % shift old events according to number of new
                        % data arrived:
                        for iP = 1:numPlotFigures
                            eventBuffers{iP}(:,1:2) = eventBuffers{iP}(:,1:2) - nData ;
                            eventBuffers{iP}( eventBuffers{iP}(:,2) < 1 , : ) = 0 ;
                        end

                    end
                    if altDataBufferIdx+nData > bufferSize
                        idx = [ altDataBufferIdx+1 : bufferSize , ...
                            1 : altDataBufferIdx + nData - bufferSize ] ;
                        altDataBuffer( idx, : ) = data ;
                        altDataBufferIdx = ...
                            altDataBufferIdx + nData - bufferSize ;
                    else
                        altDataBuffer( ...
                            altDataBufferIdx+1 : ...
                            altDataBufferIdx+nData , : ) = data ;
                        altDataBufferIdx = altDataBufferIdx + nData ;
                    end
                    if bEvents
                        try
                            evData = str2num(pnet(TCP_EVENT_SERVER,'read','noblock')) ;
                        catch
                        end
                        nNewEv = size(evData,1) ;
                        for iNewEv = 1:nNewEv
                            newEv = find( ...
                                evData(iNewEv,1)==dataBuffer(:,1) & ...
                                evData(iNewEv,2)==dataBuffer(:,2), 1,'last' ) + ...
                                evData(iNewEv,3) ;
                            if ~isempty(newEv)
                                newEvSPidx = find(cellfun(@(x)any(x==evData(iNewEv,5)),plotIndices)) ;
                                if isempty(newEvSPidx), newEvSPidx = 1:numPlotFigures; end
                                for iP = newEvSPidx
                                    eventBuffers{iP}(1:MAX_EVENTS_DISPLAYED-1,:) = ...
                                        eventBuffers{iP}(2:MAX_EVENTS_DISPLAYED,:) ;
                                    eventBuffers{iP}(MAX_EVENTS_DISPLAYED,:) = ...
                                        [newEv newEv+evData(iNewEv,4) ...
                                        evData(iNewEv,4) 1 evData(iNewEv,5)] ;
                                end
                            end
                        end
                    end
                    if ~bFrozen
                        for sp = 1:numPlotFigures
                            for iP = 1:numel(PLOT_HANDLES{sp})
                                if bXRoll
                                    set( PLOT_HANDLES{sp}(iP) , ...
                                        'YData' , dataBuffer(:,plotIndices{sp}(iP)) );
                                else
                                    set( PLOT_HANDLES{sp}(iP) , ...
                                        'YData' , altDataBuffer(:,plotIndices{sp}(iP)));
                                end
                            end
                            if bEvents
                                ylim( shandle(sp), autoYlim( ...
                                    min(vec( dataBuffer(:,plotIndices{sp}))) , ...
                                    max(vec( dataBuffer(:,plotIndices{sp}))) )) ;
                                updateFillObjXData() ;
                                updateFillObjYData() ;
                            end
                        end
                    end
                elseif nData == 0
                    % nothing to do here
                elseif  nDim ~= DIM
                    warning('TB_SCOPE:damagedPacket','damaged data packages arrived')
                end
            end
            set(MSG_HANDLE,'string','conncetion closed');
        end
        
%% (sub)nested functions updateFillObjXData & updateFillObjYData
    function updateFillObjXData()
        for ii = 1:numPlotFigures
            for jj = 1:MAX_EVENTS_DISPLAYED
                set(eventObjHandles(ii,jj),'XData',eventBuffers{ii}(jj,[1 2 2 1])) ;
            end
        end
    end
    function updateFillObjYData()
        for ii = 1:numPlotFigures
            yy = get(shandle(ii),'YLim') ;
            for jj = 1:MAX_EVENTS_DISPLAYED
                set(eventObjHandles(ii,jj),'YData',yy([1 1 2 2])) ;
            end
        end
    end

    end

%%  nested function closeFigs
    function closeFigs(h,eventdata)
        disconnect() ;
        delete(PLOTFIG_HANDLE)
        delete(FIG_HANDLE)
    end

%%  nested function close_plot
    function close_plot(h,eventdata)
        set(PLOTFIG_HANDLE,'visible','off') ;
        disconnect() ;
    end

%%  nested function disconnect
    function disconnect(h,eventdata)
        set(MSG_HANDLE,'string','closing conncetion ...') ;
        set(CONNECT_HANDLE,'visible','on') ;
        set(DISCONNECT_HANDLE,'visible','off') ;
        set(FREEZE_HANDLE,'enable','off') ;
        set(PORT_HANDLE,'enable','on');
        set(ADDRESS_HANDLE,'enable','on');
        set(B_SPECTRUM_HANDLE,'enable','on');
        set(B_SPECTRUM_TEXT_HANDLE,'enable','on');
        set(CHANNEL_HANDLE,'enable','on');
        set(CHANNEL_TEXT_HANDLE,'enable','on');
        set(B_XSCROLL_MODE_HANDLE,'enable','on');
        set(TBASE_HANDLE,'enable','on');
        bConnected = false ;
        bFrozen = false ;
        set(FREEZE_HANDLE,'string','freeze')
        pnet('closeall') ;
        set(MSG_HANDLE,'string','conncetion closed');
    end

%%  nested function freeze
    function freeze(h,eventdata)
        if ~bFrozen
            bFrozen = true ;
            set(FREEZE_HANDLE,'string','continue')
        else
            bFrozen = false ;
            set(FREEZE_HANDLE,'string','freeze')
        end
    end

%%  nested function change_view
    function change_view(h,eventdata)
        if bSpectrum
            bSpectrum = false ;
        else
            bSpectrum = true ;
        end
    end

%%  nested function disp_help
    function disp_help(h,eventdata)
        disp(helptxt)
    end



%% nested function init_tbase
    function ok = init_tbase(h,eventdata)
        ok = true ;
        try
            eval(['bufferSize = ',get(TBASE_HANDLE,'string'),';']) ;
            if ~isscalar(bufferSize)
                error('BufferSize should be a scalar.') ;
            end
        catch
            warning('TB_SCOPE:wrongFormat', ...
                'Value in field ''samples'' should be scalar')
            ok = false ;
            return
        end
    end


%% nested function init_plot_indices
    function ok = init_plot_indices(h,eventdata)
        ok = true ;
        try
            eval(['plotIndices = ',get(CHANNEL_HANDLE,'string'),';']) ;
        catch
            warning('TB_SCOPE:wrongFormat', ...
                'Value in field ''channels'' should be either a vector or a cell of vectors')
            ok = false ;
            return
        end
        if iscell(plotIndices)
            maxChannelRequest = max(cellfun(@(x) max(x(:)), plotIndices)) ;
        else
            maxChannelRequest = max(plotIndices) ;
        end
    end

%%  nested function disp_channels
    function disp_channels(h,eventdata)
        if ~bConnected
            if ~init_plot_indices()
                return
            end
        end
        if isempty(plotIndices) && isempty(current_dimension)
            disp('Number of channels unkown. Connect to set the number of channels.')
        elseif isempty(plotIndices) && iscell(plotIndices)
            for iP = 1:current_dimension
                disp(['plot #',num2str(iP),' -> index: ',num2str(iP)]) ;
            end            
        elseif isempty(plotIndices) && ~iscell(plotIndices)
            disp(['plot #1 -> index: ',num2str(1:current_dimension)]) ;
        else
            for iP = 1:numel(plotIndices)
                if numel(plotIndices{iP}) > 1
                    disp(['plot #',num2str(iP),' -> indices: ',num2str(plotIndices{iP})]) ;
                else
                    disp(['plot #',num2str(iP),' -> index: ',num2str(plotIndices{iP})]) ;
                end
            end
        end
    end

%%  nested function freeze
    function toggle_xscroll_mode(h,eventdata)
        if ~bXRoll
            bXRoll = true ;
            set(B_XSCROLL_MODE_HANDLE,'string','scope')
        else
            bXRoll = false ;
            set(B_XSCROLL_MODE_HANDLE,'string','roll')
        end            
    end

%% nested function switch_gui_size
    function switch_gui_size(h,eventdata)
        p = get( FIG_HANDLE, 'Position') ;
        if p(3) == ctr_fig_s
            p(3) = ctr_fig_l;
            str = '<< less' ;
        elseif p(3) == ctr_fig_l
            p(3) = ctr_fig_s ;
            str = 'more >>' ;
        end
        set( FIG_HANDLE, 'Position', p ) ;
        set( MORE_HANDLE, 'string', str ) ;
    end

%%  nested function copy2clip
%   by Grigor Browning
    function copy2clip(h,eventdata)
        str1 = num2str(dataBuffer);
        str1(:,end+1) = char(10);
        str1 = reshape(str1.',1,numel(str1));
        str2 = [' ',str1];
        str1 = [str1,' '];
        str1 = str1( ( double(str1)~=32  | double(str2)~=32 ) & ...
            ~( double(str2==10) & double(str1)==32 ) );
        str1(double(str1)==32) = char(9);
        clipboard('copy',str1);
    end

end

%% subfunction initFillObj
function h = initFillObj
h = fill( [0 1 1 0], [0 0 1 1], [0.8 0.8 0.6], ...
    'Clipping','off', ...
    'EraseMode','xor', ...
    'FaceAlpha',0.25, ...
    'EdgeColor','none', ...
    'Visible','on' ) ;
end

%% subfunction autoYlim
function yl = autoYlim(mi,ma)
if mi==ma, mi = 0.99*ma; end
r = 10^floor(log10(ma - mi)) ;
yl = [ round( floor( mi/r)*r ) ...
    round( ceil( ma/r)*r ) ] ;
end

function v = vec(a)
v = a(:);
end

