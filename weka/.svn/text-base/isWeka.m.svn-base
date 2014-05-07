function ok = isWeka(verbose)

if (exist('verbose')~=1) verbose = 0; end;
ok = 1;

if ~usejava('jvm')
    if (verbose>0)
        error('JAVA not loaded.');
    end;
    ok = 0;
end;
if isempty(strfind(javaclasspath, 'weka.jar'))
    if (verbose>0)
        error('WEKA not installed?!');
    end;
    ok = 0;    
end;
