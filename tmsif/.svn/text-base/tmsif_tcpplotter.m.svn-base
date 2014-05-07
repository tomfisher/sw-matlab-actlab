function tmsif_tcpplotter(feature_proc)
%TB_SCOPE
%   Simple scope for david's fancy data streaming toolbox.
%   Connects to an IP socket via Peter Rydes�ter's pnet toolbox 
%   to scope the data streamed over TCP/IP.
% 
%   'freeze' Halts the plot figure, while the data is aquired in the
%            background.
%   'copy'   Copies the the last 1000 aquired data samples to the
%            clipboard.
%   Quit the program by closing the control window.
% 
%   In 'spectrum'-mode it is assumed that you use the
%   TimeStampedLinesEncoder. Therefore the first two features are not
%   displayed.
% 
%   requirements:
%   - TCP/UDP/IP Toolbox 2.0.5
%   - MATLAB 7.0
% 
%   How to get Peter Rydes�ter's TCP/UDP/IP Toolbox 2.0.5 
%   - Download it from, e.g.,
%         http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=345 
%   - Extract the files to any directory.
%   - Assuming that you extracted it to 'c:\pnet' type addpath('c:\pnet')

cur_ver = 0.2 ;
%% change history:
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
% georg:::csn:::umit

    disp(['CSN:::TB_SCOPE v',num2str(cur_ver)])

    helptxt = help(mfilename) ;

    if exist('pnet','file') ~= 3
        disp('Peter Rydes�ter''s TCP/UDP/IP Toolbox is not installed properly.')
        disp(['Type ','<a href="matlab:help tb_scope">help ',...
              mfilename,'</a> for more information.'])
        return
    end
    if str2double( version('-release') ) < 14
        error('''tb_scope'' requires MATLAB 7 or higher') ; 
	end

	if (exist('feature_proc','var')~=1)
		feature_proc = @tmsif_featurewrapper;
	end;
	
%%  inits
    bFrozen = false ;
    CONNECTED = false ;
    SCREENSIZE = get(0,'ScreenSize') ;
    BUFFER_SIZE = 600 ;
    BUFFERUPDATE_SIZE = 128;
    YELLOW = [0.9 0.9 0.1] ;
    B_SPETCTRUM_START_IDX = 3 ;
    B_SPETCTRUM = false ;
    buttonPos = [10 10] ;
    buttonSiz = [60 20] ;
    DATA_BUFFER = [] ;

%%  gui inits
    FIG_HANDLE = figure('Position',[10 40 buttonSiz(1)*4+buttonPos(1)*5 ...
                                          buttonSiz(2)*3+buttonPos(2)*4],...
        'Name','csn:::tb_scope:::control', 'NumberTitle','off', ...
        'Visible','off', 'BackingStore','off', 'MenuBar','none', ...
        'Resize','off', 'CloseRequestFcn', @closeFigs ) ;
    PLOTFIG_HANDLE = figure('Position', [SCREENSIZE(3)*0.1 SCREENSIZE(4)*0.2 SCREENSIZE(3)*0.8 SCREENSIZE(4)*0.8],...
         'Name','csn:::tb_scope:::plot', 'NumberTitle','off', ...
         'Visible','off', 'BackingStore','off','Color','k', ...
         'DoubleBuffer', 'on', 'renderer', 'OpenGL', ...
         'CloseRequestFcn', @close_plot) ;
    figure(FIG_HANDLE) ;

    MSG_HANDLE = uicontrol( 'style','text', ...
        'position',[buttonPos(1) buttonPos(2)*3.5+buttonSiz(2)*2 ...
                    buttonSiz(1)*4+buttonPos(2)*3 buttonSiz(2)], ...
        'BackgroundColor',[0.8 0.8 0.8], 'FontSize',11, ...
        'FontWeight','bold', 'FontName','FixedWidth', ...
        'string','http://csn.umit.at/');

    CONNECT_HANDLE = uicontrol( 'string','connect', ...
        'position', [buttonPos buttonSiz], ...
        'callback', @tb_connect, 'interruptible','on' ) ;
    DISCONNECT_HANDLE = uicontrol( 'string','disconnect', ...
        'position', [buttonPos buttonSiz], ...
        'callback', @disconnect, 'interruptible','off', 'visible','off') ;
    FREEZE_HANDLE = uicontrol( 'string','freeze',  ...
        'position',[buttonPos(1)*2+buttonSiz(1)*1 buttonPos(2) buttonSiz], ...
        'callback', @freeze, 'enable','off' ) ;
    uicontrol( 'string','help', ...
        'position',[buttonPos(1)*3+buttonSiz(1)*2 buttonPos(2) buttonSiz], ...
        'callback', @disp_help ) ;
    uicontrol( 'string','copy', ...
        'position',[buttonPos(1)*4+buttonSiz(1)*3 buttonPos(2) buttonSiz], ...
        'callback', @copy2clip, 'interruptible','off' );

    B_SPECTRUM_TEXT_HANDLE = uicontrol( 'style','text','FontSize',8,'string','spectrum', ...
        'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
        'position',[buttonPos(1)*4+buttonSiz(1)*3 buttonPos(2)*3.3+buttonSiz(2)*1 buttonSiz] ) ;
    B_SPECTRUM_HANDLE = uicontrol( 'style','checkbox','string','', 'BackgroundColor',[0.8 0.8 0.8], ...
        'position',[buttonPos(1)*4+buttonSiz(1)*3 buttonPos(2)*2+buttonSiz(2)*1 buttonSiz], ...
        'callback', @change_view, 'FontSize',7 );
    
    uicontrol( 'style','text','FontSize',8,'string','Port', ...
        'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
        'position',[buttonPos(1) buttonPos(2)*3.3+buttonSiz(2) buttonSiz] ) ;
    PORT_HANDLE = uicontrol( 'style','edit', 'string','7688', 'BackgroundColor',[1 1 1], ...
        'position',[buttonPos(1) buttonPos(2)*2+buttonSiz(2) buttonSiz] ) ;
    uicontrol( 'style','text','FontSize',8,'string','IP address', ...
        'HorizontalAlignment','left', 'BackgroundColor',[0.8 0.8 0.8], ...
        'position',[buttonPos(1)*2+buttonSiz(1) buttonPos(2)*3.3+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;
%     ADDRESS_HANDLE = uicontrol( 'style','edit', 'string','localhost', 'BackgroundColor',[1 1 1], ...
%         'position',[buttonPos(1)*2+buttonSiz(1) buttonPos(2)*2+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;
    ADDRESS_HANDLE = uicontrol( 'style','edit', 'string','129.132.131.201', 'BackgroundColor',[1 1 1], ...
        'position',[buttonPos(1)*2+buttonSiz(1) buttonPos(2)*2+buttonSiz(2) buttonSiz(1)*2+buttonPos(2) buttonSiz(2)] ) ;

%%  nested function tb_connect
    function tb_connect(h,eventdata)
        clf(PLOTFIG_HANDLE) ;
        set(PLOTFIG_HANDLE,'visible','on') ;
        set(CONNECT_HANDLE,'visible','off') ;
        set(DISCONNECT_HANDLE,'visible','on') ;
        set(FREEZE_HANDLE,'enable','on') ;
        set(B_SPECTRUM_HANDLE,'enable','off');
        set(B_SPECTRUM_TEXT_HANDLE,'enable','off');
        figure(PLOTFIG_HANDLE)
        IP_ADDRESS = get(ADDRESS_HANDLE,'string');
        PORT = get(PORT_HANDLE,'string');
        set(MSG_HANDLE,'string','connecting ...');
        IP_STRING = IP_ADDRESS;
        TCP_SERVER = pnet('tcpconnect',IP_STRING,PORT);
        if TCP_SERVER >= 0
            set(MSG_HANDLE,'string',['connected to ',IP_STRING]);
            CONNECTED = true;
        end
        if TCP_SERVER >= 0
            set(MSG_HANDLE,'string',['connected to ',IP_STRING]);
            B_SPETCTRUM
            % get number of subplots
            DIM = 0;
            while DIM == 0
                if (isempty(feature_proc))
                    data = str2num(pnet(TCP_SERVER,'readline'));
                else
                    data = str2num(pnet(TCP_SERVER,'readline'));
                    ODIM = size(data,2);
                    data = feval(feature_proc, []);
                end;
                DIM = size(data,2);
            end;
            fprintf('\n%s: Data dimensions: %u', mfilename, DIM);
            datatmp = zeros(BUFFERUPDATE_SIZE, ODIM);
            DATA_BUFFER = zeros(BUFFER_SIZE,DIM);
            
            for d = 1:DIM
                DATA_BUFFER(:,d) = DATA_BUFFER(:,d) + data(d);
            end
%             xnsp = ceil(sqrt(DIM));
%             ynsp = ceil(DIM/xnsp);
            for d = 1:DIM
                shandle = subplot(DIM,1,d);
                PLOT_HANDLES(d) = plot(1:BUFFER_SIZE,DATA_BUFFER(:,d), ...
                    'Color',YELLOW);
                set(shandle, 'XGrid','on','YGrid','on', ...
                    'Color','k','XColor',YELLOW,'YColor',YELLOW, ...
					'YLimMode', 'manual', 'YLim', [0 4e3]);
			end
			set(subplot(DIM,1,DIM), 'YLim', [-5 5]); % last plot is Digi :)

            %try
                while CONNECTED
% 					disp('read data...');

%                     nDatatmp = 100;
%                     datatmp = circshift(datatmp, [-nDatatmp 0]);
%                     for i = 1:nDatatmp
%                         datatmp(end-nDatatmp+1+i,:) = str2num(pnet(TCP_SERVER,'readline')); %'read','noblock'));
%                     end;
                    
                    tmp = str2num(pnet(TCP_SERVER,'read','noblock'));
                    if isempty(tmp)  pause(0.01); continue; end;

                    [nDatatmp dummy] = size(tmp);

                    if (nDatatmp > BUFFERUPDATE_SIZE)
                        fprintf('\n%s: Lost data points: %u', mfilename, nDatatmp-BUFFERUPDATE_SIZE);
                        tmp = tmp(end-BUFFERUPDATE_SIZE+1:end,:);
                        [nDatatmp dummy] = size(tmp);
                    end;
                    datatmp = circshift(datatmp, [-nDatatmp 0]);
                    datatmp(end-nDatatmp+1:end,:) = tmp;

%                     datatmp = [datatmp(nDatatmp+1:end,:); tmp];


                    %if isempty(tmp) continue; end;


                    if (~isempty(feature_proc))
                        data = feval(feature_proc, datatmp);
                    else
                        data = datatmp;
                    end;

                    [nData,nDim] = size(data);
                    
                    if nData > 0 && nDim == DIM
                        DATA_BUFFER = circshift(DATA_BUFFER,[-nDatatmp 0]);
                        DATA_BUFFER(end-nDatatmp+1:end,:) = data(end-nDatatmp+1:end,:);
%                         DATA_BUFFER = circshift(DATA_BUFFER,[-nData 0]);
%                         DATA_BUFFER(end-nData+1:end,:) = data(end-nData+1:end,:);


                        if ~bFrozen
% 					disp('prepare plot...');
                                for d = 1:DIM 
                                    set(PLOT_HANDLES(d),'YData',DATA_BUFFER(:,d));
                                end
                            end
%                     elseif nData == 0
%                         pause(0.01)
                    elseif  nDim ~= DIM
                        warning('damaged data packages arrived')
                    end
                end
                set(MSG_HANDLE,'string','conncetion closed');
%             catch
%                 warning(lasterr)
%             end
        end

    end

%%  nested function closeFigs
    function closeFigs(h,eventdata)
        disconnect ;
        delete(PLOTFIG_HANDLE)
        delete(FIG_HANDLE)
    end

%%  nested function close_plot
    function close_plot(h,eventdata)
        set(PLOTFIG_HANDLE,'visible','off') ;
        disconnect ;
    end

%%  nested function disconnect
    function disconnect(h,eventdata)
        set(MSG_HANDLE,'string','closing conncetion ...') ;
        set(CONNECT_HANDLE,'visible','on') ;
        set(DISCONNECT_HANDLE,'visible','off') ;
        set(FREEZE_HANDLE,'enable','off') ;
        set(B_SPECTRUM_HANDLE,'enable','on');
        set(B_SPECTRUM_TEXT_HANDLE,'enable','on');
        CONNECTED = false ;
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
        if B_SPETCTRUM
            B_SPETCTRUM = false ;
        else
            B_SPETCTRUM = true ;
        end
    end

%%  nested function disp_help
    function disp_help(h,eventdata)
        disp(helptxt)
    end

%%  nested function copy2clip
%   by Grigor Browning
    function copy2clip(h,eventdata)
        str1 = num2str(DATA_BUFFER);
        str1(:,end+1) = char(10);
        str1 = reshape(str1.',1,prod(size(str1)));
        str2 = [' ',str1]; 
        str1 = [str1,' ']; 
        str1 = str1( ( double(str1)~=32  | double(str2)~=32 ) & ...
                   ~( double(str2==10) & double(str1)==32 ) );
        str1(double(str1)==32) = char(9); 
        clipboard('copy',str1);
    end

end

