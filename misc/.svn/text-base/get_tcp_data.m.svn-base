%function tb_connect(h,eventdata)

        CONNECTED = false;
        IP_ADDRESS = 'localhost';
        PORT = 7688;
        IP_STRING = IP_ADDRESS;
        TCP_SERVER = pnet('tcpconnect',IP_STRING,PORT);
        TCP_SERVER
%         sockcon=pnet('tcpsocket',PORT),
%         sockcon
%         if (sockcon > 0) TCP_SERVER = pnet(sockcon,'tcplisten');
%         else
%             TCP_SERVER = pnet('tcpconnect',IP_STRING,PORT);
%         end
        
        iterations = 0;
        
        if TCP_SERVER >= 0
            disp('connected to ') 
            disp(IP_ADDRESS);
            CONNECTED = true;
        end
        if TCP_SERVER >= 0
      
                DIM = 0;
                while DIM == 0
                    data = str2num(pnet(TCP_SERVER,'read','noblock'));
                    DIM = size(data,2);
                end
                

%             else
%                 % get number of subplots
%                 DIM = 0;
%                 while DIM == 0
%                     data = str2num(pnet(TCP_SERVER,'readline'));
%                     DIM = size(data,2);
%                 end
%                 DATA_BUFFER = zeros(BUFFER_SIZE,DSIM);
%                 for d = 1:DIM
%                     DATA_BUFFER(:,d) = DATA_BUFFER(:,d) + data(d);
%                 end
%                 xnsp = ceil(sqrt(DIM));
%                 ynsp = ceil(DIM/xnsp);
%                 for d = 1:DIM 
%                     shandle = subplot(xnsp,ynsp,d);
%                     PLOT_HANDLES(d) = plot(1:BUFFER_SIZE,DATA_BUFFER(:,d), ...
%                         'Color',YELLOW);
%                     set(shandle, 'XGrid','on','YGrid','on', ...
%                         'Color','k','XColor',YELLOW,'YColor',YELLOW);
%                 end

          try
                while CONNECTED
                    iterations = iterations + 1;
                    if (iterations == 5) 
                        CONNECTED = false;
                    end
                    data = str2num(pnet(TCP_SERVER,'read','noblock'))
                    
                    [nData,nDim] = size(data);
                    if  nDim ~= DIM
                        data
                        warning('damaged data packages arrived')
                    end
                end
          catch
              warning('general error, type "lasterror" for more information :')
          end

          pnet('closeall');
          
        end
