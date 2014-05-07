% ITERATOR - Compiles MEX function from 'MATLAB' expressions. Version 1.0 Beta
%
%  Copyright (C) 2001-2002, Peter Rydesäter 2002-11-12, Peter.Rydesater@mh.se
%
%  GNU Public License.
%
%
% 1. INTRODUCTION
% ================
% 
% Expressions that operates element by element on large arrays can be much
% faster if it operates more local. By compiling the expression with a C-
% compiler It can perform all operation in each element before going to next
% element. MATLAB normally executes one operation at a time on all elements
% before going on to next operator. ITERATOR generates (and compiles) c-source
% with the expression and all interfacing between MATLAB and the expression.
% ITERATOR supports converting a MATLAB expression with scalar only operations,
% "SCALARLAB", but it lets that expression iterate over all elements in all
% arrays and thereby getting it vectorized. This makes ITERATOR excellent to
% vectorize algorithms which that normally is impossible to vectorize in an
% efficient way. As the operation works more localy the bad effect of memory
% bandwidth limitation (in ordinary MATLAB) is decreased important and the
% performances of the CPU core is more importants. This makes it succesfull
% to use threads and multiple CPUs on at least the more complex expressions.
% With options to ITERATOR you can use multiple CPUs mostly without any
% changes to your expressions.
% 
% Example:
% 
%  ITERATOR [R]=myfun(A,B) R=sqrt(A.*A+B.*B)
% 
% (More examples in section 6)
% 
% This creates a C function in a file with the name myfun.c and then compiles
% it with the command MEX to get a MATLAB MEX-function named myfun.dll or
% myfun.mex* depending on platform. You can then run it with large arrays as
% input with matching sizes.
% 
% 2 GENERAL SYNTAX
% =================
% 
% All arguments to ITERATOR is strings and can be expressed in three ways;
% single-line, multi-line and external file. Each are explained below. If
% some arguments are going to be variable, then you have to use the
% functional form of of any syntax. The FUNCTION_PROTOTYPE parts of the
% declaration is expanded below to RETARGS, FUNCTIONNAME and ARGS.
% In MATLAB 5.x you often need to enclose each argument with '...' to not have
% it splitted. In MATLAB 6.x its only non bracketed arguments containing spaces
% that cause split between arguments. Iterator checks if the specified
% mexfile allready exists and checks if its contents is the same. Iterator will
% only generate a new script if the contets is changed.
% 
% SINGLE LINE SYNTAX is usefull to have in top of matlab-scripts that generates
% mex-files from simple expressions. Single line syntax:
%  
%     ITERATOR [OPTIONS...] [RETARGS...]=FUNCTIONNAME(ARGS...) EXPRESSIONS...
% 
% 
% MULTI LINE SYNTAX uses a global variable to "stack" options and expressions
% into and when the line with the "-end" is presents, it will be processed.
% This makes it usefull when you whant to make iterator mex files inline
% but you whant to break the lines and line up the expression to make it
% more readable. Multi line syntax:
% 
%     ITERATOR -stack [OPTIONS]
%     ITERATOR . [RETARGS...]=FUNCTIONNAME(ARGS... )
%     ITERATOR . EXPRESSION1...
%     ITERATOR . .....
%     ....
%     ITERATOR -end
% 
% 
% EXTERNAL FILE SYNTAX opens an m-file and compiles it as an iterator to a
% mexfile. This makes it possible to run it as an ordinary function-m-file first
% and then turn it into a iterator mex-file. The iterator will ignore the line
% beginning with "function..." because iterator proably needs a prototype with
% more options. Iterator options and function prototype are specified as an
% "comment" line beginning with  %# where the # char distingues it from an
% ordinary comment line. Lines ending with the comment %ONLYMATLAB% will be
% ignored of iterator but executed of matlab. External file syntax:
% 
%     ITERATOR FILENAME.m [OPTIONS]
% 
% Example file:
% 
%     % This is a comment line in "myfun.m"
%     % This is the MATLAB prototype
%     function X=myfun(A,B)
%     % This is the ITERATOR prototype
%     %#  X=myfun(A,B)  
%     X=A+B;
%     % Following line executed only in matlab
%     whos X      %ONLYMATLAB%
% 
% 
% Functional form of the syntax:
%  
%     ITERATOR('OPTIONS'...,'[RETARGS]=FUNCTIONNAME(ARGS...)','EXPRESSIONS'...)
% 
% 
% 3 OPTIONS
% =========
% 
% Here follows a list of all options that can be added as the first arguments
% to iterator:
% 
% -debug
%      Turns on printing of a lot of information about whats going in when
%      ITERATOR interprets the function prototype and expressions.
% 
% -debugstop
%      Like -debug but stops processing before calling the C-compiler to
%      compile created c-source.
% 
% -quiet
%      No printout at all during processing exept for errors.
% 
% -clean
% -clean filename*
% -clean path/filename*
%      This option are meant to be used alone to remove old ITERATOR
%      mex-functions and it c-source. It uses DIR to find mex-files and then
%      calls them without aruments to find if each file is actually created
%      with ITERATOR. Both the binary mex-file (eg. *.dll) for the actual
%      platform and its source are removed.
% 
% -cleanmex
%      Works exactly as -clean but remove only the binary mex file.
% 
% -cleanc
%      Works exactly as -clean but remove only the source file. Needs the binary
%      mexfiles left for verificion.
% 
% -varargs
%      Normaly the FUNCTION_PROTOTYPE specifies a fixed number of input and
%      return arguments. This option makes it possible to call the function
%      with fewer input and return arguments then the FUNCTION_PROTOTYPE
%      specifies. The default value 0 used for each non specified argument
%      unless the FUNCTION_PROTOTYPE specifies any other default value.
% 
% -type
%      Specifies default datatype for declarations that do not has the type
%      specified.
% 
% -typecast
%      When calling an ITERATOR function with an argument of a datatype other
%      then specified in the FUNCTION_PROTOTYPE, it will call the type casting
%      functionm to convert it. 
% 
% -force
%      Force to always rebuild the mexfunction. Normaly when calling ITERATOR
%      for creation of an ITERATOR function, ITERATOR first investigats if its
%      really needed or if the old mex-function evaluates the same expressions.
% 
% -nocheck
%      Force to skip some checking of input data. This can avoid some trouble
%      at an erlie step but can show up during C compilation or runtime.
% 
% -errorfun functionname
%      Specifies an alternative function to which the call is trapped if the
%      arguments miss match and causeses an error. This can be used as an
%      an way of creating suport for alternative syntaxes with same function
%      name or, just as pure error handling. The function that is called can
%      be a MATLAB script function, an other iterator function or any
%      other mex-function.
%           
% -file filename
%  filename
%      This option implements the external file syntax of the ITERATOR command.
%      The '-file' can actually be excluded, by only specifying the name in the
%      place of the FUNCTION_PROTOTYPE, it finds out from the missing () that
%      it is a filename. As ordinary MATLAB m-file % is used as start of
%      comment  and  the  keyword  'function' is or can be placed before the 
%      FUNCTION_PROTOTYPE.
%     
% -cpu   number_of_cpus
% -cpuminsize  min_elements
%      This two options is used to turn on and setup multi cpu support based
%      on POSIX threads. When option -cpu sets number of cpus to 2 or more CPU
%      it inserts a lot of extra C code includning some POSIX pthread calls
%      to support slicing up the problem. But the iterator function will split 
%      up in number_of_cpus threads at runtime if number of array elements is
%      more than min_elements. The default value for -cpuminsize is 5000 but
%      may change in future.
% 
% -fastmath
%      On linux platform this sets the -ffast-math to the gcc compiler that
%      forces it to use a faster implementation of trigometric function like
%      cos, sin and sqrt. The result may not conform strictly to the IEEE
%      specification for some input value. see the gcc manual.
% 
% -pipeline
%      Partly unrolls the iterator loop into segments of at the the moment 16
%      iterator steps. For short loops the calculation pipeline in the CPU is
%      emptied and extra clock cycles is need when jumping back and start over
%      next step of the iterator loop expression. This option avoids this by
%      onroll the loop. It makes only sense on simple expressions especially
%      without loops in set of iterator expressions.
% 
% -stack args...
%  .     args...
% -end
%      Theese three options gives support to easy make inline definition of
%      iterator function with a MULTI_LINE SYNTAX. It makes is possible to
%      make one iterator function with multiple calls to ITERATOR. This is
%      only to make typing easier and more pritty. The argument -stack starts
%      to store trailing arguments in a global variable. The '.' (dot) argument
%      adds trailing arguments to the global variable and when ITERATOR at last
%      is called with the argument -end ITERATOR start to interpret all that is
%      stored in the variable.
% 
% -default args...
% -default
%      This option stores all trailing arguments containing options in a global
%      default options variable. These options are then inserted before other
%      options at all at ITERATOR statements. A call to ITERATOR with the
%      -default option without trailing arguments removes all default options.
%      This can be usefull if you for an example want to distribute the -cpu
%      option to all iterator statments without changing every were.
% 
% 
% 4 FUNCTION PROTOTYPE
% ====================
% 
% The syntax of the FUNCTION_PROTOTYPE is similar to the function prototyping
% with the FUNCTION keyword in MATLAB. The purpos is to tell how to pass and
% and treat input and return arguments during runtime. The difference from
% MATLABS FUNCTION is that its more static at runtime, you can not use
% VARARGIN and VARARGOUT but you have a lot of other powerfull keywords with
% which you boost the speed at runtime and make the code generation more easy
% and powerfull. The function prototype look as follows:
% 
% [RETARGS...]=FUNCTIONNAME(ARGS...)
%     
% The function name can be any of your choise just as with m-files, and will be
% the name of the mexfile as well as the c-source. The parentesis around the
% input arguments must alway be there even if there is no arguments (strange
% case). There should always also be square brackes, [], around the return
% argument unless there is only one argument with no leading keyword.
% Bee carefull with extra spaces, especially in MATLAB 5.x and when not
% enclosed with '...'. Mainly is the syntax of input and return arguments 
% the same with some exceptions. Input arguments declare variables thas
% is readonly, unless you delcare is as an reference variable. Return arguments
% are declared as read and writeable. The arguments is specified as a comma
% separated list of variable names. Each with optional leading space separated
% keywords. Here is the syntax for one input or return argument.
% 
% DATATYPES AND LEADING KEYWORDS
% ------------------------------
% 
%   keyword1 keyword2 ... variable_name(dimdec1, ..... dimdec6 )
% 
% The trailing brace section is optional to open up some dimentions for
% access instead of automatic iteration over the elements. More about the
% dimention declaration later. The variable can be a NON ITERATOR, its just
% a plain scalar variable if no trailing brace section is specified. Else
% it can be a ITERATOR, a "window" sliding over the elements, moving one
% one step for each iteration. If the first letter of the variable_name is
% in uppercase the variable is by default an "iterator" (sliding window),
% if in lowercase it is not a iterator. This can the leading keywords overide.
% 
% List of keywords:
%  Datatype keywords:
%    int8    Signed integer of 8-bits 
%    int16   Signed integer of 16-bits 
%    int32   Signed integer of 32-bits 
%    int64   Signed integer of 64-bits, only for local variables
%    uint8   Unsigned integer of 8-bits 
%    uint16  Unsigned integer of 16-bits 
%    uint32  Unsigned integer of 32-bits 
%    uint64  Unsigned integer of 64-bits, only for local variables 
%    single  Floating point number 32-bits,
%    double  Floating point number 32-bits, default type
%    char    Character representation in 16-bits
%  Other keywords:
% *  cast    Do typecast of this argument.
% *  nocast  No typecast of this argument, overrides option -typecast
%    noiter  Non iterator, overides letter uppercase.
%    iter    Iterator over all iterator dimentions, overides letter lowercase.
%    iter1   Iterator over 1st iterator dimention.
%    iter2   Iterator over 2nd iterator dimention. 
%    iter3   Iterator over 3rd iterator dimention.
%    iter4   Iterator over 4th iterator dimention.
%    iter5   Iterator over 5th iterator dimention.
%    iter6   Iterator over 6th iterator dimention.
%    global  Get/set variable from/to the global workspace if not present.
%    caller  Get/set variable from/to the caller workspace if not present.
%    base    Get/set variable from/to the base workspace if not present.
% *  &       Argument is passed by reference, modified in callers workspace.
%    shape   This argument holds the dimentions for the iteraror space.
%    reshape hold Returned shape of iterator dimentions.
% 
% *This keywords has no effect on return arguments.
% 
% If conflicting keywords is specified for same variable the last one will
% overide the erlier one. The the referens keyword/character can be placed
% before the variable name without any space. A small "trick" makes it possible
% to make the input variables properly writeable and thereby use it as a
% reference variable. Modifiacations of it effect it in the callers workspace.
% This makes is possible two make functions that modifies data in an efficient
% way instead of return a modfied copy with is the tradiotional way in matlab.
% 
% 
% ARRAYS IN ITERATOR
% ------------------
% 
% If parantesis section is present as index to the variable, then it holds
% a coma separated declarations of dimentions:
% 
%   ...variable_name(dim1,....,dimN),....
%   ...variable_name(iterxx,dim1,....,dimN),....
%   ...variable_name(dim1,....,dimN,iterxx),....
% 
% For a non iterator variable dimentions dim1 ... dimN are size of dimentions
% that should be open for access and not iterated over. If the keyword "iter"
% or "iter1" ... "iter6"  is specified as first or last argument it specifies
% that iterator should iterate over the first or last dimension depending on
% where it is specified to be. Note that if you give the keyword "iter" as the
% first or last dimention that will korespond to an variable number of
% dimentions.
% 
% or for return variables you can create it equal sized as an input array
% by using the keyword 'sizeas':
% 
%   ...return_variable_name(sizeas input_variable_name)
% 
% or take the dimention length values from the elements of an input array
% 
% 
% For a non iterator variable a call in runtime  will cause an error if the
% number of dimentions of the passed variable do not match. For an iterator
% variable that iterates over the first dimentions the last dimentions must
% match. Actually only the total number of elements in this dimentions need to
% be equal. And for an iterator iterating over the last dimentions (se the
% keyword 'last') the number of the elements in the first dimentions need to
% be equal.
% The number of dimentions is static but the size of it can be static or
% dynamic from call to call. Sizes of arrays can not be modified inside the
% call to the iterator function. Following list show the different syntaxes
% of dimention size declaration where N and M whould be replace by an integer
% value:
% 
%      M       Static sized to range from 1 to M
%      N:M     Static sized to range from N to M
%      inf     Dynamic sized to rage from 1 to any size.
%      N:inf   Dynamic sized to range from N to any size.
% 
% If the start of the range is moved from MATLABs default of 1 to some other
% value, you will still reach the first element at that possition, its not a
% cutting operation. And the length of the range must fit. A static sized
% dimention cuase an error directly when calling it with an array wrong
% dimention length. By specifying inf (infinity) it will be dynamic in size
% (from call to call, not during run of the iterator) but slower because
% indexing and checking of it must be done at run time.
% 
% 5 EXPRESSIONS IN THE "SCALAR-LAB" ENVIRONMENT
% ==============================================
% 
% Like a MATLAB function can you write a sequence of expressions that is
% evaluated. iterator implements "SCALAR-LAB" which is similar to MATLAB syntax
% to make it easy to use for the MATLAB user. The main different is that the
% operations only suports scalar operations. It can access individual elements in
% arrays basically because that iterator "moves" the variable "window" over
% all elements for the array and evaluates the expressions for each step. This
% applies to variables declared as iterator variables. Other variables will
% not "move" its variable window. However if you have declared the variable
% as an array, then you can access the individual elements.
% 
% Assigments to an non declared variable will cause it to automaticaly be
% declared as local variables inside the iterator loop. If the variable is
% an array (it has index specified) then you must declare it with a declaration
% statement similar to declarations of arguments. This becase iteraror needs to
% know at initialization the space to allocate. A declaration can be placed
% anyware among all expressions but at top (first) is most proper.
% 
% Local declaration statements prototypes as follows:
% 
%    DATATYPE VARIABLENAME;             % Dec. of local scalar (normaly not needed)
%    DATATYPE VARIABLENAME(INDEX....);  % Dec. of local array
% 
% Scalars can be auto declared from expression lines like this:
% 
%    VARIABLENAME = THIS + IS * AN / EXAMPLE;
%    DATATYPE VARIABLENAME = THIS + IS * AN / EXAMPLE;
%    VARIABLENAME=DATATYPE(THIS + IS * AN / EXAMPLE);    % MATLAB COMPATIBLE 
% 
% the last example uses the typecasting function to typecase (if needed)
% and indicate destination type. 
% 
% Typecasting can can be used inside calculations as well and this type casting
% functions are supported:
% 
%     Y=double(X)
%     Y=single(X)
%     S=char(X)
%     I=int(X)
%     I=int8(X)
%     I=int16(X)
%     I=int32(X)
%     I=int64(X)
%     I=uint8(X)
%     I=uint16(X)
%     I=uint32(X)
%     I=uint64(X)
% 
% 
% Following execution flow control statements are supported in this "SCALARLAB"
% environment. Note that only scalar expressions are supported and "for" will
% not get its values from each value in a array, actually N will step from A to
% C with stepsize B, the result will anyway be the same as in MATLAB.
% 
%      if expression, elseif ... else ... end     
%      switch... case ... otherwise ... end
%      for N=A:B:C, .... end
%      for N=A:C, .... end
%      while expression, ..... end
% 
% 
% Supported mathematic function and constants:
% 
%      pi sin() cos() tan() asin() acos() atan() atan2() sqrt() log() log10()
%      power() mod(X,Y) round(X) power(X,Y)
% 
% And other functions  in standard ANSI C and "math.h".
% 
% 
% To get length of a dimention ( D ) of a variable ( X ) then use:  
% 
%      N=size(X,D)
% 
% 
% But to get length of a dimention of the iterarator space insert the
% keyword "iter" as variable name:
% 
%      N=size(iter,D)
% 
% 
% The length of the longest dimention of a varible is returned with this:
% 
%      N=length(X)
%      N=length(iter)   % For the iterator space.
% 
% 
% Following returns number of dimentions, not realy needed for iterator arrays
% as its number of dimentiuons is allways constant. But numer of dimentions of
% the iterator space may vary depending on input arrays. This gives the number
% of dimentions:
% 
%      N=ndims(X)
%      N=ndims(iter)
% 
% 
% Following functions are implemeneted to generate errors, display scalar number and
% strings:
% 
%      error('Error message')  % Will break at end of the iterator loop.
%      disp(X)                 % Print a scalar number to the screen 
%      disp('string')          % Print a string to the screen.
% 
% 
% Following returns the pointer to a specified element ( n ) in an array (X):
% 
%      pointer( X(n) )
% 
% 
% 
% 6 EXAMPLES
% ============
% 
% 1) A simple and typical expression where ITERATOR gives effect:
% 
%      iterator Y=myfun(X1,X2) Y=sin(X1).*cos(X2)
%      A=rand(1024,1024);
%      B=rand(1024,1024);
%      R=myfun(A,B)
% 
% 
% 
% 2) Same as 1) but with accelerated implementation of sin/cos in gcc & linux:
% 
%      iterator -fastmath Y=myfun(X1,X2) Y=sin(X1).*cos(X2)
%      A=rand(1024,1024);
%      B=rand(1024,1024);
%      R=myfun(A,B)
% 
% 
% 
% 3) Same as 2) but with use of 2 CPU:
% 
%      iterator -fastmath -CPU 2 Y=myfun(X1,X2) Y=sin(X1).*cos(X2)
%      A=rand(1024,1024);
%      B=rand(1024,1024);
%      R=myfun(A,B);
% 
% 
% 4) The euclidean length of the vectors along the last dimension in an array can
%    be calculated by following itererator. The keyword iter at the place for the
%    first dimention correspond to any number of leading dimentions, which in this
%    case means that only the last dimentions will be reduced.
% 
%      iterator Y=euclen(X(iter,1:3)) Y=sqrt(X(1)*X(1)+X(2)*X(2)+X(3)*X(3))
%      A=rand(1000000,3);
%      L=euclen(A);
%      
%      A=rand(10,100,1000,3); 
%      L=euclen(A);     
% 
%      L=sqrt(sum(A.^2));   % Corresponding MATLAB expression.
% 
% 
% 5) In MATLAB a multidimentional function of arrays along the different dimensions
%    uses MATLABs MESHGRID to expand the arrays to multidimentional arrays first
%    before executing the expression. This is a wast of memory usage and there by
%    slow. ITERATOR has built in support for iteratating different variables over
%    different dimentions which eleminates the need of MESHGRID.
% 
% 
%      X=0:2*pi/1000:2*pi;
%      iterator -fastmath -pipeline Z=mycossin(iter1 X,iter2 Y) Z=cos(X).*sin(Y)
%      Z=mycossin(4*X,7*X);
%      imagesc(Z);
% 
%      % Corresponding in MATLAB
%      [XX,YY]=meshgrid(4*X,7*X);
%      Z=cos(XX).*sin(YY); 
%      imagesc(Z);
%      
% 6) ITERATOR implements calculations using differents datatypes directly which
%    gives much faster calculations and saves memory.
% 
%      iterator [uint8 R]=uint8add(uint8 A,uint8 B) R=A+B
%      X=uint8(100*rand(1024));
%      Y=uint8(100*rand(1024));
% 
%      R=uint8add(X,Y);
% 
%      % Corresponding MATLAB expression.
%      R=uint8(double(Xii)+double(Xi));
% 
% 7) By passing variables by reference is it possible to modify variables instead
%    of returning a new value. This saves memory badwidth and and under a short
%    momemt it also saves memory. The '&' symbol is used to declare a variables
%    as passed by reference.
% 
%      iterator -fastmath tosin(&V) V=sin(V)
%      X=2*pi*rand(1024,1024);
% 
%      tosin(X);
% 
%      %Corresponding MATLAB expression:
%      X=sin(X);
%      
% 
% 8) With the option -varargs ITERATOR compiles a function that can take a
%    variable number of arguments. When not all paramters are supplied at a
%    function call a default value are used for that parameter. It tries no
%    use the C compiler to optimize for that consant values.
% 
%      iterator -fastmath -varargs R=muladd(B=0,c=1,D=0,e=1) R=B*c+D*e
%      X=rand(1024,1024);
%      Y=rand(1024,1024);
%      
%      R=muladd(X, 1.5,   Y, 2.33)
%      R=muladd(X, 1.5,   Y)
%      R=muladd(X, 1.5)
%     
% 9) Variable number of output arguments, gives some optimization by the fact
%    that the C compiler makes some optimization when a returned variables
%    not going to bee used.
% 
%     iterator -fastmath -varargs [CO,SQ4]=cossq4(X) CO=cos(X) SQ4=CO*CO*CO*CO
%     X=rand(1024,1024);
%     [a,b]=cossq4(X);  % Fast
%     [a]  =cossq4(X);  % Faster
% 
% 10) With the argument -errorfun you can specify an alternative function to which
%     the call should be passed if something fails like, datatypes, number of arguments,
%     or shape of the arrays. In this case this function calls its implementation for
%     the uint16 datatype if then call to the main function fail.
% 
%       iterator s=muladdsum_1(uint16 X,uint16 Y) init: s=0 iter: s=s+double(X)*double(Y)
%       iterator -errorfun muladdsum_1 s=muladdsum(X,Y) init: s=0 iter: s=s+double(X)*double(Y)
% 
% 
% 11) A m-file script containing loops dealing with scalar numbers can be really well accelerated
%     with ITERATOR. Following m-file is possible to run as m-file directly from MATLAB but also
%     Compile it with ITERATOR to a mex file. the script is typical for encryption or other codecs.
%
%     Contents of the m-file mysequence.m     
%
%       % This is demo
%       function x=mysequence(pattern,data)
%       % This is the ITERATOR prototype
%       %#  [x( sizeas data )]=mysequence(noiter pattern(1:10),noiter data(1:inf))
%       %
%       %# int n;
%       %# int idx;
%       %  
%          idx=1;
%          N=size(data,1)*size(data,2);
%          for n=1:N,
%            x(n)=data(n)+pattern(idx);
%            idx=1+floor(idx+data(n));
%            while idx>10,
%              idx=idx-10;
%            end
%          end
%          return;
%
%    
%    You can run the script from matlab with this expression:
%
%          X=rand(128,128);
%          R=mysequence(1:10,X);
%
%    And you can then compile it and run it more than 100 times faster as a mex with this:
%
%          iterator mysequence.m
%          R=mysequence(1:10,X);
%
%
%   
% 
% More examples in next release!
% Do you have some nice example?
% 
% 
%
% 7 COPYRIGHT AND LICENSE
% =======================
%
%  Copyright (C) 2001-2002, Peter Rydesäter
%
%  GNU Public License.
%
%  This program is free software; you can redistribute it and/or
%  modify it under the terms of the GNU General Public License
%  as published by the Free Software Foundation; either version 2
%  of the License, or (at your option) any later version.
%  
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%
%
% --END-OF-DOCUMENTATION--
%

function iterator(varargin)  
  DEF.IDSTR='ELEMENT ITERATOR Version 1.0 Beta (C) 2001-2002 Peter Rydesäter';
  global ITERATOR_DEFAULT;
  global ITERATOR_STACK;
  DEF.CONTENTSID='';
  if nargin==0,  return;  end
  
  %% CECH IF FIRST ARGUMENT IS AN M-FILE? => Read it%%
  filename=varargin{1};
  filenamerev=filename(end:-1:1);
  if strncmp(filenamerev,'m.',2) | strncmp(filenamerev,'m.i.',4),
    st=dir(filename);
    if length(st)~=1,
      error(['Iterator input file not found: ' filename]);
    end
    DEF.CONTENTSID=[DEF.IDSTR ' ' filename ' ' st.date];
    file = textread(['./' filename],'%s','delimiter','\n','whitespace','');
    lst={'-contentsid',DEF.CONTENTSID,varargin{2:end} };
    for n=1:length(file),
      str=strtrim(file{n});      
      if strncmp(str,'function ',9),
	% Just skip the function line...	
	lst{end+1}=['MATLAB_COMMENT( /* MATLAB PROTOTYPE: ' str ' */ )'];
      elseif strncmp(str(end:-1:1),'%BALTAMYLNO%',12),
	% Just skip the "...... %ONLYMATLAB%" line... by making it to a comment.
	lst{end+1}=['MATLAB_COMMENT( /* ' str ' */ )'];
      elseif strncmp(str,'%#',2),
	splst=str_split(str(3:end), ' ',' ');
	for m=1:length(splst),
	  str=splst(m).str;
	  if ~strcmp(str,'iterator'),
	    lst{end+1}=str;
	  end
	end
      elseif strncmp(str,'%',1),
	lst{end+1}=[' MATLAB_COMMENT( /* ' str(2:end) ' */ )'];
      else
	comlst=str_split(str,'% ','%',2);
	if(length(comlst)>1)
	  lst{end+1}=[' MATLAB_COMMENT( /* ' comlst(2).str ' */ )'];
	end
	lst{end+1}= comlst(1).str;
      end
    end
    iterator(lst{:});
    return;
  end
  %% End of M-File reading.
  
  if length(ITERATOR_DEFAULT)==0,
    ITERATOR_DEFAULT={};
  end
  varargin=[ ITERATOR_DEFAULT(:) ; varargin(:)]; % Add default options.  
  quiet=0;
  DEF.DEBUG=0;
  force=0;
  clean=0;
  DEF.VARARGS=0;
  DEF.WSUSE=0;
  DEF.WSNAME='';
  DEF.CPU=1;
  DEF.MULTI_CPU_MINSIZE=5000;
  DEF.TYPECAST=0;
  DEF.TYPE='double';
  DEF.NOCHECK=0;
  DEF.ERRORFUN='';
  DEF.FASTMATH=0;
  DEF.PIPELINE=0;
  DEF.UNSAFEINDEX=0;
  DEF.MAKEFUN=0;
  %%%%%%%%
  fun='';
  % Find options and function declaration
  n=1;
  while n<=length(varargin),
    str=strtrim(varargin{n});
    while length(str)<1,
      n=n+1;
      str=strtrim(varargin{n});
    end    
%    if strncmp('function ',str,9),
%      varargin{n}=varargin{n}(9:end);
%    end
    n=n+1;
    switch lower(str),
     case '-contentsid'
      DEF.CONTENTSID=[varargin{n}];
      n=n+1;
     case '-stack',
      ITERATOR_STACK=varargin(n:end);
      return;
     case '.',
      try,
	ITERATOR_STACK=[ITERATOR_STACK(:);varargin(n:end)];
      catch,
	error 'Probably trying to stack iterator lines outside stack segment'
      end
      return;
     case '-end',
      try,
	varargin=[varargin(:);ITERATOR_STACK(:)];
	ITERATOR_STACK=[nan];
      catch,
	error 'Probably trying to stack iterator lines without start of stack option (-stack).'
      end
     case '-default',
      ITERATOR_DEFAULT=varargin(n:end);
      return;
     case '-irun',
	irun_analyze(varargin(n:end), evalin('caller','who') );
	return;
     case '-debug',
      DEF.DEBUG=1;
     case '-quiet',
      quiet=1;
     case '-debugstop',
      DEF.DEBUG=2;
     case '-clean',
      clean=1;
     case '-cleanmex',
      clean=2;
     case '-cleanc',
      clean=3;
     case '-varargs',
      DEF.VARARGS=1;
     case '-typecast',
      DEF.TYPECAST=1;
     case '-force',
      force=1;
     case '-nocheck',
      DEF.NOCHECK=1;
     case '-callerws',
      DEF.WSUSE=1;
      DEF.WSNAME='caller';
     case '-globalws',
      DEF.WSUSE=1;
      DEF.WSNAME='global';
     case '-type',
      DEF.TYPE=varargin{n};
      n=n+1;
     case '-errorfun',
      DEF.ERRORFUN=varargin{n};
      n=n+1;      
     case '-cpu',
      DEF.CPU=str2num(varargin{n});
      if length(DEF.CPU)==1,
	n=n+1;
      else
	DEF.CPU=1;
      end
     case '-cpuminsize',
      DEF.MULTI_CPU_MINSIZE=str2num(varargin{n});
      if length(DEF.MULTI_CPU_MINSIZE)==1,
	n=n+1;
      end
     case '-fastmath',
      DEF.FASTMATH=1;
     case '-pipeline',
      DEF.PIPELINE=1;
     case '-unsafeindex',
      DEF.UNSAFEINDEX=1;
     case '' 
      % Skip emtpy option
     otherwise,
      if str(1)=='-',
	error(['Unknown option: ' str]);
      end
      break; % Quit option read loop
    end
  end
  
  % Get C-Expression
  n=n-1;
  cexp={};
  fun='';
  while n<=length(varargin),
    str=strtrim(varargin{n});
    if length(str)==0,
      
    elseif length(fun)==0 & ~strncmp(str,'MATLAB_COMMENT(',15);
	fun=str;
    else
      cexp{end+1}=str;
    end
    n=n+1;
  end
  DEF.CEXP=cexp;

  
  
  % post process options
  if DEF.DEBUG,
    quiet=0;
  end
  [DEF.TYPE,DEF.CTYPE]=lut_type(DEF.TYPE);
  
  % CLEAN specified path from iterators if it is a clean option
  if clean,
    if length(fun)==0,
      fun='*';
    end
    lst=dir([fun '.' mexext]);
    mem_path=path;
    try,
      for n=1:length(lst),
	[fp,fn,fe]=fileparts(lst(n).name);
	addpath(fp,'-begin');
	try,
	  if strncmp(feval(fn),'ELEMENT ITERATOR ',16), 
	    if clean==1 | clean==2,
	      if quiet==0, disp(['DELETES ITERATOR:  ' fullfile(fp, [fn,'.', mexext])]); end
	      delete(fullfile(fp, [fn,'.', mexext]));
	    end
	    if clean==1 | clean==3,
	      if quiet==0, disp(['DELETES C-SOURCE:  ' fullfile(fp, [fn,'.c'])]); end
	      delete(fullfile(fp, [fn,'.c']));
	    end
	  end
	end
      end
    end
    path(mem_path);
    return;
  end
  
  if DEF.DEBUG,
    disp ' '
    disp '===Function declaration==='
    disp(fun);
    disp ' '
    disp '===Element operator expression==='
    disp(char(DEF.CEXP));
    disp ' '
  end
  
  %% Extract function name
  zfun=str_zero_subs(fun);
  idxstart=[find(zfun=='=')+1,1];
  idxstart=idxstart(1);
  idxend=[find(zfun(idxstart:end)==char(0))-3,0]+idxstart;
  DEF.FUN=zfun(idxstart:idxend(1));

  % If no contentsid is created until now then create it.
  if  isempty(DEF.CONTENTSID),
    DEF.CONTENTSID=sprintf('%s ',DEF.IDSTR,varargin{:});
  end
  
  % Reuse the mex-file if this version is already compiled.
  if DEF.DEBUG==0 & force==0,
    try,
      strnow=feval(DEF.FUN);
      if strcmp(strnow,DEF.CONTENTSID),  % Verify that it is not changed.
	if DEF.DEBUG==1,
	  disp(['Recycle already compiled function! :', DEF.FUN] );
	end
	return;
      end
    end
  end  
  r=which(DEF.FUN);
  if length(r),
    try,
      if strncmp(feval(char(r)),'ELEMENT ITERATOR ',16)==0,
	error 'Not a element iterator...'
      end
    catch,
      if quiet==0,
	disp( ['ITERATOR REPLACING: ',char(r) ]);
      end
    end
  end

  stret=str_split(fun,'=','[]',1);
  if length(stret)>1,
    DEF.RET=str_split(stret(1).str, ',',' ()[]');
    stret=stret(end);
  else
    DEF.RET=[];
  end
  stin=str_split(stret(1).str,'()',' ()');
  DEF.IN =str_split( stin(2).str ,',',' ()[]');
  
  DEF.LOC=[];
    
%  stdef=str_split(stin(3).str,'[]',' []');
%  if length(stdef)>=2,
%    DEF.LOC =str_split( stdef(2).str ,',',' ()[]');
%  else
%    DEF.LOC =[]
%  end
  
  DEF.IN=class_arg(DEF.IN,DEF);
  [r,DEF]=class_arg(DEF.RET,DEF);
  DEF.RET=r;  
  DEF=MATLAB_to_C(DEF);
  
  try, [DEF.RET(1:end).ret]=deal(1); end
  try, [DEF.IN(1:end).in]=deal(1);   end
  try, [DEF.LOC(1:end).loc]=deal(1); end
  DEF.ALL=[];
  if length(DEF.IN ) DEF.ALL=[DEF.ALL DEF.IN ]; end
  if length(DEF.RET) DEF.ALL=[DEF.ALL DEF.RET]; end
  if length(DEF.LOC) DEF.ALL=[DEF.ALL DEF.LOC]; end
  unique_dec(DEF)
    
  if DEF.DEBUG>0,
    def_list(DEF);
  end
          
%  if DEF.DEBUG,
%    list_struct(DEF);
%  end
  
  if DEF.DEBUG>1,
    return;
  end
    
  f=fopen([DEF.FUN,'.c'],'w');
  fline(f);
  create_mex_main(DEF);
  fclose(f);
  
  if DEF.DEBUG,
    disp 'C-Source:' 
    disp ' '
    type([DEF.FUN '.c']);  
    disp ' '
    disp ' '
    disp ' '
    disp 'Compile c-source to mex-file...'
  end
  opt={'-O'};
  if str2num(version('-release'))==13,
    opt{end+1}='-V5';
  end
  try,
    clear(DEF.FUN)
    if DEF.FASTMATH & strcmp(computer,'GLNX86'),
      opt{end+1}='CFLAGS="-fPIC\ -ansi\ -D_GNU_SOURCE\ -pthread\ -ffast-math"';
    end
    mex([DEF.FUN '.c'],opt{:});    
  catch,    
    error(['========= Sorry, Error from C-Compiler! ============'])
  end
  return; 

function irun_analyze(args,wholst)
   funname_str=irun(args{:});
   % in loc ret
   symlst={};
   lhsvarlst={};
   expstr=[' ',list2str(args,'  '),' '];
   expstr=strrep(expstr,'==','$$');
   expstr=strrep(expstr,'=',' = ');
   expstr=strrep(expstr,'$$','==');
   str=expstr;
   
   %MAKE LEFT HAND SIDE VARIABLE LIST
   retexplst=str_split(expstr,' ',' ');
   retexplst={retexplst(:).str};
   eqidx=strmatch('=',retexplst,'exact');
   for ii=eqidx(:)',
     lhstr=retexplst{ii-1};
     lhlst=str_split(lhstr,'()','() ');
     lhsvarlst{end+1}=lhlst(1).str;
   end   
   %MAKE LIST OF SYMBOLS THAT MAY BE VARIABLES
   msk=( isletter(str) | (str>='0' & str<='9') | str=='_' | str=='=');
   str(find(~msk))=' ';
   nummsk=double((1:length(msk)).*msk);
   strlst=str_split(str,' ',' ');
   strlst(end+1).str='';  % Dummy, to avoid later errors
   lh_counter=1;
   for n=1:length(strlst),
     str=strlst(n).str;
     if strcmp(strlst(n).str,'='),
       lasteqidx=n;
     elseif isvarname(str),
	 symlst{end+1}=str;
     end
   end
   symlst=unique(symlst);
   symlst=setdiff(symlst,lhsvarlst);
   in_lst={};
   for n=1:length(symlst),
     if ~strcmp(which(symlst{n}),'built-in'),
       in_lst{end+1}=symlst{n};       
     end
   end
   
   ret_lst=lhsvarlst(end);
   loc_lst=lhsvarlst(1:end-1);
   war_lst=setdiff(in_lst,wholst);
   
   expstr=strrep(expstr,' =','=');
   expstr=strrep(expstr,'= ','=');
   disp(['IRUN            EXPRESSION: ' expstr]);
   disp(['IRUN  INPUT VARIABLES FROM:' sprintf('  %s',in_lst{:})]);
   disp(['IRUN    INTERNAL VARIABLES:' sprintf('  %s',loc_lst{:})]);
   disp(['IRUN   RETURN VARIABLES TO:' sprintf('  %s',ret_lst{:})]);

   if length(war_lst),
     error(['IRUN ERROR! DO NOT KNOW THIS SYMBOLS:' sprintf('  %s',war_lst{:})]);
   end
   
   ret_str=list2str(ret_lst,',');
   for n=1:length(loc_lst)
     args=[{sprintf('double %s; ',loc_lst{n})} , args(:)'];
   end
   in_str=list2str(in_lst,',');
   protostr=sprintf('[%s]=%s(%s)',ret_str,funname_str,in_str);
   disp(['IRUN    FUNCTION PROTOTYPE: ' protostr]);
   disp(['IRUN             ARGUMENTS: ' sprintf('  %s',args{:})]);
   iterator('-typecast','-callerws',protostr,args{:})
   return;     
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DEF=MATLAB_to_C(DEF)
  E=[{'iter:'};DEF.CEXP(:)];  %% Add default label
  OPSL='+-*/|&=><~(';
  OPSR='+-*/|&=><~)';
  if DEF.DEBUG,
    disp '======= SCALAR MATLAB Expression ========'
    disp(E(:)')
  end
  
  %% PASS 1 %%      Split strings into keywords, ops
  NE={};
  nn=0;
  while nn<length(E),
    nn=nn+1;
    str=E{nn};
    %% TODO: Not split '%'... replace with /* */
    
    S=str_split(str,',; ',' ');
    NE={NE{:} S(1:end).str};
  end
  E=NE;
  if DEF.DEBUG,
    disp '======= Split Expression ========'
    disp(E')
  end
  
  %% PASS 2 %%      Split at assignment
  NE={};
  nn=0;
  while nn<length(E),
    nn=nn+1;
    S=str_split(E{nn},'=',' ');
    if length(S)>2,
      S(2).str=list2str({S(2:end).str},'=');
    end
    if length(S)>=2,
      s1c=[' ' S(1).str];
      s2c=[S(2).str ' '];  
      s1=[S(1).str];
      s2=[S(2).str];
      if sum(s1c(end)=='~><')+sum(s2c(1)=='=')>0, %IS NOT A ASSIGNMENT OP??
	  NE{end+1}=E{nn};
      else
	%IT IS AN ASSIGNMENT OP...
	if sum(s1c(end)=='+-*/')>0,
	  NE={NE{:} s1(1:end-1) [s1(end) '='] s2};
	elseif sum(s2c(1)=='=')>0, 
	  NE={NE{:} s1(1:end-1) s1 '==' s2(2:end)};
	else	  
	  NE={NE{:} s1 '=' s2};
	end
      end
    else
      NE{end+1}=E{nn};
    end
  end
  E=NE;
  if DEF.DEBUG,
    disp '======= Split Expression at "=" ========'
    disp(E')
  end
  %% PASS 3 %%      Pack & remove
  NE={};
  nn=0;
  while nn<length(E),
    nn=nn+1;
    str=strtrim(E{nn});
    if length(str),
      NE{end+1}=str;
    end
  end
  E=NE;
  if DEF.DEBUG,
    disp '======= Pack Expression ========'
    disp(E')
  end

  %% Init emptylist of local scalars
  declst={};
  dectypelst={};  
  
  %% find declarations and extract it. %%
  DEF.CEXP=E;
  [E,dec]=extract_declaration(DEF);
  [stdec,DEF]=class_arg(dec,DEF);
    stdec2=stdec([]);
  for n=1:length(DEF.LOC)
    if length(stdec(1).index),
      stdec2(end+1)=stdec(n);
    else
      declst{end+1}=stdec(n).name;
      dectypelst{end+1}=stdec(n).type;
    end
  end
  DEF.LOC=stdec2;
   
  %% Identify assignments %%
  idxlst=strmatch('=',E);
  for ch='+-*/',
    idxlst=sort([idxlst(:);strmatch([ch '='],E)]);
  end
  allst=[DEF.IN, DEF.RET, DEF.LOC];
  indexlst={allst(:).index};
  indexaslst={allst(:).indexasname};
  indexfromlst={allst(:).indexfromname};  
  nameslst={allst(:).name};
  
  for idx=idxlst(:)',
    S=str_split(E{idx-1},'(',' ');
    name=S(1).str;
    if isempty( strmatch(name,nameslst) ),
      if length(S)>1,
	if DEF.NOCHECK==0,
	  error 'You must declare arrays, Only scalars can be auto declared.'
	end
      else
	% Autodeclare scalars
	indexlst{end+1}=[];
	indexaslst{end+1}='';
	indexfromlst{end+1}='';
	nameslst{end+1}=name;
	% To be declared
	declst{end+1}=name;
	type=DEF.TYPE;
	S=str_split(E{idx+1},'(','()');
	possible_type=S(1).str;
	try, type=lut_type(S(1).str); end
	dectypelst{end+1}=type;
      end
    else
      idx=strmatch(name,nameslst,'exact');
      if length(indexaslst{idx(1)})>0,
	idx=strmatch(indexaslst{idx},nameslst,'exact');
      elseif length(indexfromlst{idx(1)})>0,
	idx=strmatch(indexfromlst{idx},nameslst,'exact');
	if length(idx)==1 & isempty(indexlst{idx}),
	  indexlst{idx}=[1 1];   % Work around to avoid error.
	end	  
      end      
      if (length(S)>1)~=(length(indexlst{idx(1)})>0 ),	
	error(['Use of variable index "' name '" not matching declaration']);
      end
    end
  end
  DE={'init:'};
  %% Declare identifed non decared scalar variables
  for nn=1:length(declst),
    [type,ctype]=lut_type(dectypelst{nn});
    DE{end+1}=sprintf('%s %s',ctype,declst{nn});
  end
  E=[DE E];
  
  %% PASS 4 %%  Merge keywords into expressions & replace MATLAB ops
  NE={};
  nn=0;
  while nn<length(E),
    nn=nn+1;
    flag=1;
    if length(E{nn})>0 & length(NE)>0,
      if sum(NE{end}(end)==OPSL) | sum(E{nn}(1)==OPSR),
	s1=NE{end}(max(end-1,1):end);
	s2=E{nn}(min(end,2):end);
	if ~(strcmp(s1,'++') | strcmp(s2,'++') | strcmp(s1,'--') |strcmp(s2,'--')),
	  NE{end}=[NE{end},' ',E{nn}];
	  flag=0;	   
	end
      end
    end
    if flag, NE{end+1}=E{nn}; end
    NE{end}=strrep(NE{end},'|','||');
    NE{end}=strrep(NE{end},'||||','||');
    NE{end}=strrep(NE{end},'&','&&');
    NE{end}=strrep(NE{end},'&&&&','&&');
    NE{end}=strrep(NE{end},'~','!');
    NE{end}=strrep(NE{end},'.*','*');
    NE{end}=strrep(NE{end},'./','/');
    if ~isempty(findstr(NE{end},'^')), error 'Operator ^ not supported, use exp(...)', end
    if strncmp(NE{end},'disp(''',6), NE{end}=strrep(NE{end},'disp(''','dispstr("');NE{end}=strrep(NE{end},'''','"'); end
    if strncmp(NE{end},'error(''',7), NE{end}=strrep(NE{end},'error(''','error("');NE{end}=strrep(NE{end},'''','"'); end
  end
  E=NE;
  if DEF.DEBUG,
    disp '======= Merge Expression ========'
    disp(E')
  end
  
  %% PASS 5 %%      Replace MATLAB expressions with C expressions
  NE={};
  nn=0;
  flag_CTL=0;
  while nn<length(E),
    nn=nn+1;
    Estr=E{nn};
    switch(Estr)
     case 'elseif'
      Estr='}else if';
    end
    switch(Estr)
     case {'if' '}else if' 'while'}
      NE{end+1}=[Estr '(' E{nn+1} '){'];
      nn=nn+1;
     case 'switch'
      NE{end+1}=[Estr '((int)' E{nn+1} '){'];
      nn=nn+1;
     case 'case'
      if ~strncmp(NE{end},'switch(',7), NE{end+1}='break;'; end
      NE{end+1}=['case ' E{nn+1} ':'];
      nn=nn+1;      
     case 'otherwise'
      if ~strncmp(NE{end},'switch(',7), NE{end+1}='break;'; end
      NE{end+1}='default:';
     case 'else'
      NE{end+1}='}else{';
     case 'end'
      NE{end+1}='}';
     case 'return'
      NE{end+1}='goto _continue_this_loop_;';
      flag_CTL=1;
     case 'for'      
      S=str_split(E{nn+1},'=',' ');
      SC=str_split(S(2).str,':',' ');
      var=S(1).str;
      start=SC(1).str;
      stop=SC(end).str;
      step='1';
      if length(SC)>2, step=SC(2).str; end
      stepnum=str2num(step);
      if length(stepnum)==0,
	op=sprintf('((%s>0)?(%s>=%s):(%s<=%s))',step,var,stop,var,stop);
      elseif stepnum>0,
	op=sprintf('%s<=%s',var,stop);
      else
	op=sprintf('%s>=%s',var,stop);
      end
      NE{end+1}=sprintf('for(%s=(%s); %s; %s+=(%s)){',var,start,op,var,step);
      nn=nn+1;
     otherwise
      if Estr(end)==':',	
	NE{end+1}=[Estr];
      else
	NE{end+1}=[Estr ';'];
      end
    end
  end  
  level=0;
  for n=1:length(NE),
    if NE{n}(1)=='}', level=level-1;, end
    if strncmp('case ',NE{n},5), level=level-0.5; end
    if strncmp('default:',NE{n},8), level=level-0.5; end
    blankstr=char(ones(1,level*4).*32);
    if NE{n}(end)=='{', level=level+1; end
    if strncmp('case ',NE{n},5), level=level+0.5; end
    if strncmp('default:',NE{n},8), level=level+0.5; end
    NE{n}=[blankstr,NE{n}];
  end
  
  if flag_CTL,
    NE{end+1}='iter:';
    NE{end+1}='_continue_this_loop_:';
  end
  if DEF.DEBUG,
    disp '======= C-Expression ========'
    disp(NE')
  end
  
  if level~=0,
    error 'Non matching number of end in expression'
  end
  DEF.CEXP=NE;
  return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%% Extracts declarations from expression
function [ret,dec]=extract_declaration(DEF)
  ret={}; 
  dec={};
  decstack={};
  for nn=1:length(DEF.CEXP),
    exp=DEF.CEXP{nn};
    %% Check if it is a declaration keyword
    if ~isempty(lut_type(exp,'noerror')) | ~isempty(strmatch(lower(exp),{'iter','noiter'},'exact')),
      decstack{end+1}=exp;      
    else
      f_keep=1;
      if ~isempty(decstack),
	dec{end+1}=list2str([{'noiter'},decstack,{exp}],' ');	
	% Remove expression if only declaration.
	if nn==length(DEF.CEXP),
	  f_keep=0;
	elseif isempty(strmatch(DEF.CEXP{nn+1},{'=','*=','/=','+=','-='},'exact')),
	  f_keep=0;
	end
      end
      if f_keep,
	ret{end+1}=exp;      
      end
      decstack={};
    end    
  end
  return;
            
% Remove surounding blanks
function s=strtrim(s);
  s=deblank(s(end:-1:1));
  s=deblank(s(end:-1:1));
  return;
  
% Remove split string in arguments returned as struct array
function R=str_split(str,sep,remove_char,no),
  zstr=str_zero_subs(str);
  idx=[];
  for nn=1:length(sep),
    idx=sort([idx,strfind(zstr,sep(nn))]);
  end
  if nargin>3,
    idx=idx( no(find(no<=length(idx))) );
  end
  idx= [0,idx, length(str)+1];
  for n=1:length(idx)-1,
    sidx= idx(n)+1:idx(n+1)-1;
    p_str=strtrim( str( sidx ) );
    R(n).str=str_remove_char(p_str,remove_char);
  end
  return;

% Sets all chars inside brackets, {}[]()'' to 0
function [zstr, lev]=str_zero_subs(str)
  lv=0;
  strflag=0;
  zstr='';
  lev=zeros(size(str));
  if(length(str)==0),
    return;
  end
  for n=1:length(str),
    if strflag==0,
      if find(str(n)==']})'), lv=lv-1; end
      lev(n)=lv;
      if find(str(n)=='[{('), lv=lv+1; end
      if str(n)=='''', lv=lv+1; strflag=1; end
    else
      if str(n)=='''', lv=lv-1; strflag=0; end
      lev(n)=lv;
    end
  end
  zstr=char((lev==0).* double(str));
  return
  
  % Remove sorounding chars from string
function str=str_remove_char(str,remove_char)
  while(length(str)),
    if length(findstr(remove_char,str(1)))==0 ,
      break;
    else
      str=str(2:end);
    end
  end
  while(length(str)),
    if length(findstr(remove_char,str(end)))==0 ,
      break;
    else
      str=str(1:end-1);
    end
  end
  return;
  
% LOOK UP DATATYPE
function [type,ctype]=lut_type(type,mode)
  typealiaslutlst= {'int'};
  typealiaslst= {'int32'};
  typelst= {'double','single','char',     'int8','int16',    'int32',   'uint8',        'uint16',            'uint32'};
  ctypelst={'double','float' ,'short int','char','short int','long int','unsigned char','unsigned short int','unsigned long int'};  
  idx=strmatch(lower(strtrim(type)),typealiaslutlst,'exect');
  if length(idx),
    type=typealiaslst{idx};
  end
  idx=strmatch(lower(strtrim(type)),typelst,'exect');
  if isempty(idx),
    if nargin<2,
      error ['Uknown datatype:' type],
    end
    type='';
    return;
  end
  type=typelst{idx};
  ctype=ctypelst{idx};
  return;
%
% Check that declaration is unique
%
function unique_dec(DEF)
  names={DEF.ALL(:).name};
  for n=1:length(names),
    idx=strmatch(names{n},names,'exact');
    if length(idx)>1,
      error(sprintf('Redeclaration error: variable %s declared %d times as input, return or local variable',...
		    names{n},length(idx)) );
    end
  end
  return;
  
 % Classify return/input arguments
function [A,DEF]=class_arg(I,DEF)
  if isempty(I),
    A=[];
    return;
  end
  if isstruct(I),
    for n=1:length(I),
      [A(n),DEF]=class_arg(I(n).str,DEF);
    end
    return;
  end
  if iscell(I),
    for n=1:length(I),
      [A(n),DEF]=class_arg(I{n},DEF);
    end
    return;
  end  
  A.type=DEF.TYPE;
  [A.type,A.ctype]=lut_type(A.type);
  A.defvalue=0;
  A.byref=0;
  A.in=0;
  A.ret=0;
  A.loc=0;
  A.shapearg=0;
  A.reshapearg=0;
  A.lastdims=0;
  A.iterdim=0;
  A.typecast=DEF.TYPECAST;
  A.wsuse=DEF.WSUSE;
  A.wsname=DEF.WSNAME;
  A.indexasname='';
  A.indexfromname='';
  A.index=[];  % Supose Just a simple single element
  
  % Separate ending default value specification
  Fdef=str_split(I,'=',' []',1);
  if length(Fdef)>1,
    A.defvalue=str2num(Fdef(end).str);
  end
  if length(A.defvalue)==0,
    A.defvalue=0;
  end
  
  % Separate index inside () from variable name
  Fidx=str_split(Fdef(1).str,'(',' ()',1);
  typename=Fidx(1).str;  % Save variable name and prefix for later
  if length(Fidx)>1, % If any index inside () section at all...
    Fidx=str_split(Fidx(2).str,',',' []()');
    % check if itating dims is first or last
    if length(Fidx)>0,
      if strncmp(Fidx(1).str,'iter',4),
	A.iterdim=str2num(Fidx(1).str(5:end));	  
	if isempty(A.iterdim), A.iterdim=inf; end
	A.lastdims=0;
	Fidx=Fidx(2:end);
      elseif strncmp(Fidx(end).str,'iter',4),
	A.iterdim=str2num(Fidx(end).str(5:end));
	if isempty(A.iterdim), A.iterdim=inf; end
	A.lastdims=1;
	Fidx=Fidx(1:end-1);	  
      else
	%%%%% TODO: error...???
      end
    end
    %If "sizeas ..." in (....)
    if strncmp(lower(Fidx(1).str),'sizeas',6),
      Sidx=str_split(Fidx(1).str,'( ',' []()');
      A.indexasname=Sidx(2).str;
      idx=strmatch(A.indexasname,{DEF.IN(:).name},'exact');
      if length(idx)~=1,
	error(['Can not find one input argument "' A.indexasname '" to get sizeas for "' typename '" from.']);
      end
      %If "size ..." in (....)
    elseif strncmp(lower(Fidx(1).str),'size',4),
      Sidx=str_split(Fidx(1).str,'( ',' []()');
      A.indexfromname=Sidx(1).str;
      idx=strmatch(A.indexfromname,{DEF.IN(:).name},'exact');
      if length(idx)~=1,
	error(['Can not find one input argument "' A.indexfromname '" to get size for "' typename '" from.']);
      end
      DEF.IN(idx).typecast=1;
      DEF.IN(idx).defvalue=max(1,DEF.IN(idx).defvalue);
      [DEF.IN(idx).type,DEF.IN(idx).ctype]=lut_type('int');
    else
      for x=1:length(Fidx),
	%s Split : separeted index values of the style 'from:to' from each index string
	f2=str2num(strrep(Fidx(x).str,':',' '));
	if length(f2)==0,
	  f2=[1 1];
	elseif length(f2)==1,
	  f2=[1,f2];
	elseif length(f2)>2,
	  error( ['Bad index range: "', Fidx(x).str, '", must be 0, 1 or 2 separated numbers.'] );
	end
	A.index(x,1:2)=f2;
      end
    end
  end
  if length( A.index )>0,
    if length( A.defvalue)>1,
      M=A.index;
      idx=find(isnan(M(:)));
      M(idx)=1;
      Mdiff=M(:,2)-M(:,1);
      if sum(Mdiff<0),
	error( ['Bad index range for variable ', typename, ', A:B  B must be greater than A'] );
      end
      Mdiff=Mdiff+1;
      n=prod(Mdiff);
      if n~=length( A.defvalue),
	error(['Number of default values do not match size for variable "',typename '" .']);
      end
    end
  else
    if  length( A.index )==0 & length( A.defvalue)>1,
      error( ['Length of default value array should be 1 for variable "', typename, '" .'] );
    end
  end
  % Separate datatype and variable name
  F=str_split(strtrim(typename),' ',' ()');
  A.name=F(end).str;
  if A.name(1)=='&',
    A.name=A.name(2:end);
    A.byref=1;
  end
  
  %IF First is uppercase then its an iterator by default
  if A.name(1)==upper(A.name(1)) & A.iterdim==0, 
    A.iterdim=inf;
  end
  % Match keyword list
  for x=1:length(F)-1,
    str=F(x).str;
    try,
      [A.type,A.ctype]=lut_type(str);
    catch,
      if strncmp(str,'noiter',6),
	A.iterdim=0;
      elseif strncmp(str,'iter',4),
	A.iterdim=str2num(str(5:end));
	if isempty(A.iterdim), A.iterdim=inf; end
      elseif strcmp(str,'shape'),
	A.shapearg=1;
      elseif strcmp(str,'reshape'),
	A.reshapearg=1;
      elseif strcmp(str,'cast'),
	A.typecast=1;
      elseif strcmp(str,'nocast'),
	A.typecast=0;
      elseif strcmp(str,'&'),
	A.byref=1;
      elseif strcmp(str,'noref'),
	A.byref=1;
      elseif strcmp(str,'caller'),
	A.wsuse=1;
	A.wsname='caller';
      elseif strcmp(str,'global'),
	A.wsuse=1;
	A.wsname='global';
      elseif strcmp(str,'base'),
	A.wsuse=1;
	A.wsname='base';
      else
	warning(['Unrecognized keyword:' str]);
      end
    end
  end
  return;

%% Lists intepretation of list
function def_list(DEF)
  disp '===Function name==='
  disp(DEF.FUN)
  disp '===Input arguments==='
  list_arg(DEF.IN);
  disp '===Return arguments==='
  list_arg(DEF.RET);
  disp '===Local variables==='
  list_arg(DEF.LOC);
  return;
  
function list_arg(A)
  for n=1:length(A),
    optstr='';
    idxstr='';
    optstr=[optstr, sprintf('iter%d ',A(n).iterdim)];
    if length(A(n).index)>0,
      optstr2=sprintf('%d:%d,',A(n).index(:));
      optstr2=strrep(optstr2,'NULL','');
      optstr=[ '(' optstr2(1:end-1) ') ' optstr] ;
    end
    disp(sprintf('%-10s %-10s=%s %-6s',A(n).type, [A(n).name, idxstr] ,num2str(A(n).defvalue),optstr));
  end
  disp ' '
  return;

% Converts a list to a string separated with sep chars.  
function str=list2str(lst,sep)
  str='';
  if length(lst),
    if iscell(lst),
      str=sprintf(['%s' sep],lst{:});
    else
      str=sprintf(['%.16g' sep],lst(:));
    end
    str=str(1:end-length(sep));
  end
  return;
  
% Function for backards compatibility to matlab 5.x
%
function idx=strfind(txt,patt)
  if length(txt)<=length(patt),
    txt=sprintf('%s%s',txt,char(zeros(1,length(patt)+1)));
  end
  idx=findstr(txt,patt);
  return;
  
 
% Output C-code line to file.  
function fline(varargin),
  global FLINE_FILE;
  global FLINE_BASE;
  if length(varargin)==0,
    fprintf(FLINE_FILE,'\n');
    return;
  end
  if ischar(varargin{1})==0,
    FLINE_FILE=varargin{1};
    return;
  end
  if(varargin{1}(1)~='#')
    if varargin{1}(1)=='@',
      varargin{1}=[FLINE_BASE,varargin{1}(2:end)];
    else
      L=[find(varargin{1}~=' ')-1,0];
      FLINE_BASE=char(ones(1,L(1)).*32);
    end
  end
  
  if length(varargin)==1,
    fprintf(FLINE_FILE,'%s\n',varargin{1});
  else
    fprintf(FLINE_FILE,[varargin{1}, '\n'],varargin{2:end});
  end
  return;
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
function create_mex_main(DEF)
  fline('/* MEX-file (Plugin) for MATLAB ')
  fline('   Created with: %s',DEF.IDSTR)
  fline('   Implements function: %s',DEF.FUN);
%  fline('   Iterates expression: ');    
%  fline('@  %s',DEF.CEXP{1:end});
  fline( '*/')
  fline( '#include "mex.h"')
  fline( '#include <math.h>')
  fline( '#include <string.h>')
  print_insert_cpu(DEF,'INCLUDE');
  fline
  fline( '#define MATLAB_COMMENT(...) /* Dummy macro for matlab_comments */');
  fline
  fline( '#define _deftype_ %s',DEF.CTYPE);
  fline
  fline( '#define MAX(A,B) ((A)>(B)?(A):(B))');
  fline( '#define MIN(A,B) ((A)<(B)?(A):(B))');
  fline( '#define LIMIT(X,A,B) MIN(MAX(X,B),A)');
  fline( '#define double(X) (double)(X)');
  fline( '#define single(X) (float)(X)');
  fline( '#define char(X) uint16(X)');
  fline( '#define int(X)  int32(X)');
  fline( '#define int8(X) (char)(X)');
  fline( '#define int16(X) (short int)(X)');
  fline( '#define int32(X) (long int)(X)');
  fline( '#define int64(X) (long long)(X)');
  fline( '#define uint8(X) (unsigned char)(X)');
  fline( '#define uint16(X) (unsigned short int)(X)');
  fline( '#define uint32(X) (unsigned long int)(X)');
  fline( '#define uint64(X) (unsigned long long)(X)');  
  fline
  fline( '#define pointer(X) (&(X))');
  fline
  fline( '#define error(X) ErrStr=(X)');
  fline( '#define disp(X) fprintf(stderr,"At element %d: %.15g\n",_iter_i+1,(double)(X))');
  fline( '#define dispstr(X) fprintf(stderr,"At element %d: %s\n",_iter_i+1,(X))');
  fline( '#define mod(X,Y) ((X)%(Y))');
  fline( '#define round(X) (floor((X)-0.5))');
  fline( '#define power(X,Y) pow(X,Y)');
  fline( '#define size(X,D) (((int)(D)> _ ## X ## _no_dims_ || (int)(D)<1 )?1:_ ## X ## _dims_[(int)(D)-1])');
  fline( '#define length(X) MAX(  MAX(size(X,1),size(X,2))  ,  size(X,3)  )');
  fline( '#define ndims(X) _ ## X ## _no_dims_ ');
  
  if DEF.UNSAFEINDEX ,
    fline( '#define INDEXERR(X,mi,ma) (X)' );
  else
    fline( ['#define INDEXERR(X,mi,ma) ((X)<(mi)?'...
	    '((mi)+0*(int)(ErrStr="Index out of range")):'...
	    '((X)>=(ma)? ((ma)+0*((int)(ErrStr="Index out of range"))):(X))) '] );
  end
  fline( '#define _ERROR_FF_CALL(ERRSTR) \');
  if length(DEF.ERRORFUN),
    fline( 'do{ mexCallMATLAB(nlhs_IN,plhs_IN,nrhs_IN,(mxArray **)prhs_IN,"%s"); return; }while(0)',DEF.ERRORFUN);
  else
    fline( 'mexErrMsgTxt(ERRSTR)');
  end
  fline
  fline( 'volatile const char *ErrStr=NULL;' );
  fline  
  fline ('const int ones_dims[]={1,1};');
  fline
  print_insert_cpu(DEF,'GLOBAL');
  fline
  fline('/* FUNCTION that combine two arrays of dimention sizes and allocate an array from it*/')
  fline('mxArray *mk_iterator_NumericArray(int ndims1, const int *dims1,int ndims2,const int *dims2,mxClassID class)');
  fline('{')
  fline('    int ndims=0;')
  fline('    int dims[512];')
  fline('    if(ndims1==0)         return mxCreateNumericArray(ndims2,dims2,class,mxREAL);');
  fline('    if(ndims2==0)         return mxCreateNumericArray(ndims1,dims1,class,mxREAL);');
  fline('    if(ndims1+ndims2>512) mexErrMsgTxt("To many dimentions in array to create");')
  fline('    memcpy(&dims[ndims],dims1,ndims1*sizeof(int));');
  fline('    ndims+=ndims1;');
  fline('    memcpy(&dims[ndims],dims2,ndims2*sizeof(int));');
  fline('    ndims+=ndims2;');
  fline('    return mxCreateNumericArray(ndims,dims,class,mxREAL);');
  fline('}');
  
  %% MAKE SUM(...) AND PROD(...) FUNCTIONS
  if DEF.MAKEFUN,
    funlst={'sum' '+' '0'; 'prod' '*' '1'};
    for m=1:size(funlst,1),
      fline('#define %s(A,B,C) _%s_(pointer(A),pointer(B),pointer(C))',funlst{m,[1 1]});
      fline('inline _deftype_ _%s_(const _deftype_ *ptr,const _deftype_ *ptrnext,const _deftype_ *ptrlast)',...
	    funlst{m,[1]});
      fline('{');
      fline('    const int step=((unsigned int)ptrnext-(unsigned int)ptr)/sizeof(*ptr);');
      fline('    _deftype_ val=%s;',funlst{m,[3]});
      fline('    if((unsigned int)ptrlast<(unsigned int)ptr)');
      fline('        return val;');
      for n=[1 0],
	if n==1,
	  fline('    if(step==%d){',n)
	  fline('        const int step=%d;',n)
	elseif n~=0,
	  fline('    }else if(step==%d){',n)
	  fline('        const int step=%d;',n)
	else
	  fline('    }else{')
	end
	fline('        while(ptr<=ptrlast){');
	pipelen=16;
	fline('            const _deftype_ *pipestep=&ptr[step*%d];',pipelen);
	fline('            if(pipestep>=ptrlast){',pipelen);
	fline('                while(ptr<=ptrlast){');
	fline('                    val%s=ptr[0]; ptr=&ptr[step];',funlst{m,[2]});
	fline('                }');    
	fline('            }else{');
	for n=1:pipelen,
	  fline('                val%s=ptr[%d*step];',funlst{m,[2]},n-1);
	end
	fline('                ptr=pipestep; continue;');
	fline('            }');    
	fline('        }');
      end
      fline('    }');    
      fline('    return val;');    
      fline('}');
    end
  
    %% MAKE MULADD(...) FUNCTIONS
    funlst={'muladd' '*' '0'; 'divadd' '/' '0'};
    for m=1:size(funlst,1),
      fline(['#define %s(A1,A2,A3,B1,B2,B3) _%s_(pointer(A1),pointer(A2),pointer(A3),pointer(B1),' ...
	     ' pointer(B2),pointer(B3))'],funlst{m,[1 1]});    
      fline('inline _deftype_ _%s_(const _deftype_ *ptr1,const _deftype_ *ptr1next,const _deftype_ *ptr1last,const _deftype_ *ptr2,const _deftype_ *ptr2next,const _deftype_ *ptr2last)',funlst{m,[1]});
      fline('{');
      fline('    const int step1=((unsigned int)ptr1next-(unsigned int)ptr1)/sizeof(*ptr1);');
      fline('    const int step2=((unsigned int)ptr2next-(unsigned int)ptr2)/sizeof(*ptr2);');
      fline('    _deftype_ val=%s;',funlst{m,[3]});
      fline('    if((unsigned int)ptr1last<(unsigned int)ptr1)');
      fline('        return val;');
      for n=[1 2 0],
	if n==1,
	  fline('    if(step1==1 && step2==1){')
	  fline('        const int step1=1;',n)
	  fline('        const int step2=1;',n)
	elseif n==2,
	  fline('    }else if(step1==1){')
	  fline('        const int step1=1;')
	else
	  fline('    }else{')
	end
	fline('        while(ptr1<=ptr1last){');
	pipelen=16;
	fline('            const _deftype_ *pipestep1=&ptr1[step1*%d];',pipelen);
	fline('            const _deftype_ *pipestep2=&ptr2[step2*%d];',pipelen);
	fline('            if(pipestep1>=ptr1last){',pipelen);
	fline('                while(ptr1<=ptr1last){');
	fline('                    val+=ptr1[0] %s ptr2[0]; ptr1=&ptr1[step1]; ptr2=&ptr2[step2];',funlst{m,[2]});
	fline('                }');    
	fline('            }else{');
	for n=1:pipelen,
	  fline('                  val+=ptr1[0] %s ptr2[0];',funlst{m,[2]});
	  if(n==1)
	    fline('                  ptr1++; ptr2++;');
	  else
	    fline('                  ptr1=&ptr1[step1]; ptr2=&ptr2[step2];');
	  end
	end
	fline('            }');    
	fline('        }');
      end
      fline('    }');    
      fline('    return val;');    
      fline('}');
    end
  end %% END OF DEF.MAKEFUN (sum and prud functions)
  
  fline( 'int myGetNumberOfDimensions(const mxArray *ptr)');
  fline( '{');
  fline( '    const int *dims;');
  fline( '    int ndims=mxGetNumberOfDimensions(ptr);');
  fline( '    if(ndims>2) return ndims;');
  fline( '    dims=mxGetDimensions(ptr);');
  fline( '    if(dims[1]>1) return 2;');
  fline( '    if(dims[0]>1) return 1;');
  fline( '    return 0;');
  fline( '}');
  fline
  fline( 'const double pi=3.141592653589793115997963468544185161590576171875;');
  fline
  fline ('void mexFunction(int nlhs_IN,mxArray *plhs_IN[],int nrhs_IN, const mxArray *prhs_IN[])')
  fline('{')
  % Print declaration of variables.
  fline( '    /* Variables */' )
  fline('     mxArray *plhs[51],*prhs[51];')
  fline('     int nlhs=0,nrhs=0;')
  fline('     int _iter_start=0, _iter_stop=0, _iter_end=0,no_arg_in=0,no_arg_ret=0;')
  fline('     int _iter_no_dims_=2;')
  fline('     const int *_iter_dims_=NULL;')
  fline('     int _iter_make_dims[6]={1,1,1,1,1,1};')
  if length(find([DEF.ALL(:).reshapearg]==1))>0,
    fline( '    /* Variables to be used for "reshape" argument */' )
    fline( '    int rs_iter_end=0,rs_iter_no_dims_=0;')
    fline( '    const int *rs_iter_dims_=NULL;')
  end
  fline( '    ')
  print_insert_cpu(DEF,'LOCAL');
  fline
  fline( '    /* Input and Return Variables ToFrom MATLAB WS */')  
  fline
  print_variable(DEF,'DEC','INRET');
  fline
  print_insert_cpu(DEF,'SKIPSTART');
  fline
  fline( '    /*----Argument init section---*/ ')
  fline( '    {')
  fline( '        int idx=0;')
  fline( '             ')
  fline( '        ErrStr=NULL;')
  fline( '        if(nrhs_IN==0 && nlhs_IN==1){plhs_IN[0]=mxCreateString(\n"%s");return;}',...
	 strrep(strrep(DEF.CONTENTSID,char(10),'\n'),'"','\"'));
  %% TODO: Move this....
  %% Find index for first argument that iterates all elements
  %% => use this to check size towards later.
  fline
  fline('        do{        ')
  fline('            /* Start of breakable section */');
  fline
  print_variable(DEF,'COPYARGSIN','IN'); % Input arguments
  fline('        }while(0); /* End of breakable section */')
  fline('        nlhs=MAX(nlhs_IN,%d);',max([0,find([DEF.ALL(:).wsuse])]));
  fline
  fline('        if(nrhs_IN>%d)',length(DEF.IN));
  fline('            mexWarnMsgTxt( "Too many arguments to function %s. Argument(s) ignored.");',DEF.FUN);
  fline
  fline('        /*==============GET DIMENSIONS SIZE FOR ITERATOR============*/');
  print_variable(DEF,'GETDIMS_SHAPE','IN'); % Get Iterator dimension size from shape argument

  print_variable(DEF,'GETDIMS','IN'); % Get Iterator dimension size if not know
  
  fline('        /* If iterator dimensions not know, Compose it....*/');
  fline('        if(_iter_dims_==NULL){');
  fline('           _iter_dims_=_iter_make_dims;');
  fline('           _iter_end=1;');
  fline('           _iter_no_dims_=0;');
  print_variable(DEF,'GETDIMS2','IN');
  fline('        }')      
  fline
  fline('        if(_iter_no_dims_<=0){_iter_no_dims_=1; _iter_dims_=ones_dims;}')      
  fline
  fline('        /*==============END         GET DIMS========================*/');
  print_variable(DEF,'RESHAPE','IN'); % Get reshape dimensions
  fline('        do{')
  fline('            /*========GET ARGUMENTS======================*/')
  fline('            const mxArray *ptr=NULL;')
  print_variable(DEF,'GETARGS','IN')
  fline('        }while(0);')
  fline
  if length(find([DEF.ALL(:).reshapearg]))>0,
    fline('        /* Replace reshape dimensions with normal values if its not OK */')
    fline('        if(rs_iter_dims_==NULL || rs_iter_end!=_iter_end){' )
    fline('            rs_iter_dims_=_iter_dims_;')
    fline('            rs_iter_no_dims_=_iter_no_dims_;')
    fline('            rs_iter_end=_iter_end;')
    fline('        }')
    fline('#define _iter_dims_    rs_iter_dims_')
    fline('#define _iter_no_dims_ rs_iter_no_dims_')
    fline 
  end
  fline('        do{')
  fline('            /*========CREATE RETURN ARGUMENTS============*/')
  print_variable(DEF,'RETARGS','RET');
  fline('        }while(0);')
  fline
  if length(find([DEF.ALL.reshapearg]))>0,
    fline('/* Turn off substitute with #defines */')
    fline('#undef _iter_dims_')
    fline('#undef _iter_no_dims_')
    fline
  end  
    
  fline
  if DEF.VARARGS==0,
    fline('        if(no_arg_in!=%d ) mexErrMsgTxt("Wrong number of input variables");', length(DEF.IN));
    fline('        if(no_arg_ret!=%d) mexErrMsgTxt("Wrong number of return arguments");',length(DEF.RET));
  end
  fline('          _iter_stop=_iter_end;')
  fline('    } /* End argument Init section  */')

  print_insert_cpu(DEF,'START')
 
  if DEF.VARARGS,
    fline('     switch(no_arg_in)')
    fline('     {')
    for args_in=1:length(DEF.IN),
      fline('       case %d: /* IN CASE */',args_in)
      fline('         switch(no_arg_ret)')
      fline('         {')
      for args_ret=0:length(DEF.RET),
	fline('           case %d:    /* RET CASE */',args_ret)
	create_mex_iterator_loop(DEF,args_in,args_ret);
	fline('           break;')
      end
      fline('         }');
      fline('         break;')
    end
    fline('     }')
  else
    create_mex_iterator_loop(DEF,length(DEF.IN),length(DEF.RET));
  end
  print_insert_cpu(DEF,'STOP');

  fline('    do{        /* Start of breakable section */')
  print_variable(DEF,'COPYARGSRET','RET'); % return arguments
  fline('    }while(0); /* End of breakable section */')
  
  fline('    if(ErrStr) mexErrMsgTxt((const char *)ErrStr);' )
  
  fline('}' )
  return;
  
function create_mex_iterator_loop(DEF,args_in,args_ret)
  global FLINE_BASE;
  memFLINE_BASE=FLINE_BASE;
  
  %% Is "mesh" generation used?
  dd=[DEF.ALL(:).iterdim];
  f_mesh= (0<length(find(dd>0 & dd<=6)));
  
  fline('@/* THE ELEMENT ITERATOR LOOP  %d %d */',args_in,args_ret);
  fline('@{');
  fline('@    register int _iter_i=0; ')
  FLINE_BASE=[memFLINE_BASE '    '];
  print_variable(DEF,'DECLOC', 'LOC');
  print_variable(DEF,'DEFINE',    'IN', 1:args_in);
  print_variable(DEF,'DEFINE_NOIN','IN', args_in+1:length(DEF.IN));
  print_variable(DEF,'DEFINE',    'RET',1:args_ret);
  print_variable(DEF,'DEFINE_NORET','RET',args_ret+1:length(DEF.RET));
  print_variable(DEF,'DEFINE', 'LOC');
  fline('#define _continue_this_loop_  _continue_this_loop_%d_%d_',args_in,args_ret);
if f_mesh,
    fline('@int tmpdiv=1;');
    fline('@int _iter_i1=(_iter_no_dims_>0)?(_iter_start/(tmpdiv               ))%(_iter_dims_[0]):0;');
    fline('@int _iter_i2=(_iter_no_dims_>1)?(_iter_start/(tmpdiv*=_iter_dims_[0]))%(_iter_dims_[1]):0;');
    fline('@int _iter_i3=(_iter_no_dims_>2)?(_iter_start/(tmpdiv*=_iter_dims_[1]))%(_iter_dims_[2]):0;');
    fline('@int _iter_i4=(_iter_no_dims_>3)?(_iter_start/(tmpdiv*=_iter_dims_[2]))%(_iter_dims_[3]):0;');
    fline('@int _iter_i5=(_iter_no_dims_>4)?(_iter_start/(tmpdiv*=_iter_dims_[3]))%(_iter_dims_[4]):0;');
    fline('@int _iter_i6=(_iter_no_dims_>5)?(_iter_start/(tmpdiv*=_iter_dims_[4]))%(_iter_dims_[5]):0;');    
  end
  print_expression(DEF,'init:');
  fline('@for( _iter_i=_iter_start; _iter_i<_iter_stop; _iter_i++){')
  FLINE_BASE=[memFLINE_BASE '        '];
  if DEF.PIPELINE==0 | f_mesh,
    print_expression(DEF,'iter:');  % Default Non pipelineversion
  else
    pipelen=16;                     % experimental version using CPU pipline
    fline('@if(_iter_i+%d>=_iter_stop){',pipelen)
    FLINE_BASE=[memFLINE_BASE '            '];
    print_expression(DEF,'iter:');
    FLINE_BASE=[memFLINE_BASE '        '];
    fline('@}else{');    
    FLINE_BASE=[memFLINE_BASE '            '];
      for pipen=1:pipelen,
	if pipen>1,
	  fline('@_iter_i++;');
	end
        print_expression(DEF,'iter:');
      end
    fline('@}');
    FLINE_BASE=[memFLINE_BASE '        '];
  end
  if f_mesh,
    for nn=1:6,
      sp=char(32.*ones(1,(nn-1).*4));
      fline('@%sif((_iter_i%d++)+1==_iter_dims_[%d]){',sp,nn,nn-1);
      fline('@%s    _iter_i%d=0;',sp,nn);
    end
    strend=char(double('}').*ones(1,6));
    fline('@%s',strend);
  end
  FLINE_BASE=[memFLINE_BASE '    '];
  fline('@}');
  fline('#undef _continue_this_loop_');
  print_variable(DEF,'UNDEFINE', 'LOC');
  print_variable(DEF,'UNDEFINE', 'IN');
  print_variable(DEF,'UNDEFINE', 'RET');  
  FLINE_BASE=memFLINE_BASE;
  fline('@}');
  return;

%% Prints specified part (specified by label) of expression.
function print_expression(DEF,label)
  ret=extract_expression(DEF,label);
  if ~isempty(ret),
    fline('@%s',ret{:});
  end
  return;
  
%% Returns specified part (specified by label) of expression.
function ret=extract_expression(DEF,label)
  labelok=0;
  ret={};
  for nn=1:length(DEF.CEXP),
    exp=DEF.CEXP{nn};
    if ~isempty(strmatch(upper(exp),{'INIT:','ITER:','DEC:'},'exact'))
      if strcmp(lower(exp),label),
	labelok=1;
      else
	labelok=0;
      end
    elseif labelok==1,
      ret{end+1}=exp;
    end
  end
  return;
  
%% Prints out variable related code  
function print_variable(DEF,style,filter,lst)
  if nargin<3, filter='ALL'; end
  VLST=[];
  if 1,
    switch upper(filter),
     case 'ALL'
      VLST=DEF.ALL;
     case 'IN'
      VLST=DEF.ALL(find([DEF.ALL.in]));
     case 'RET' 
      VLST=DEF.ALL(find([DEF.ALL.ret]));
     case 'INRET'
      VLST=DEF.ALL(find([DEF.ALL.in] | [DEF.ALL.ret]));
     case 'LOC' 
      VLST=DEF.ALL(find( [DEF.ALL.loc]));
    end
  end
  if nargin>3, VLST=VLST(lst); end  
  for n=1:length(VLST),
    V=VLST(n);

    %This is an argument equal sized to an other input argument...
    if (V.ret | V.loc) & ~isempty(V.indexasname),
      Vas=DEF.ALL(strmatch(V.indexasname,{DEF.ALL(:).name},'exact'));
      V.index=Vas.index;
    else
      Vas.name='';
    end	        
    %This is an argument getting its size from contents of an input argument
    if (V.ret | V.loc) & ~isempty(V.indexfromname),
      Vfrom=DEF.ALL(strmatch(V.indexfromname,{DEF.ALL(:).name},'exact'));
      fromsi=prod(diff(Vfrom.index')+1);
      V.index=ones(fromsi,2);
      V.index(:,2)=inf;
    else
      Vfrom.name='';
    end     
    % Calculate size of subscript dimensions
    disi=diff(V.index')+1;
    if length(disi)==1, disi(2)=1; end   %%%% DEBUG TEST TEST,  DOES THIS WORK??? %%%
    si=prod(disi);
    % Create string versions
    disistr={};
    for nn=1:length(disi),
      if disi(1)==inf,
	if V.in,
%	  disistr{nn}=sprintf('_%s_dims_[%d]',V.name,nn-1);
	  disistr{nn}=sprintf('size(%s,%d)',V.name,nn);
	elseif ~isempty(Vas.name),
%	  disistr{nn}=sprintf('_%s_dims_[%d]',Vas.name,nn-1);
	  disistr{nn}=sprintf('size(%s,%d)',Vas.name,nn);
	elseif ~isempty(Vfrom.name),
	  disistr{nn}=sprintf('(%d>=_%s_elements_?1:(int)_%s_[%d])',nn-1,Vfrom.name,Vfrom.name,nn-1);
	else
	  error 'Can not find out how to size argument'
	end
      else
	disistr{nn}=sprintf('%d',disi(nn));
      end
    end
    
    if si==inf,
      if V.in,
	sistr=sprintf('_%s_elements_',V.name);
      elseif ~isempty(Vas.name),
	sistr=sprintf('_%s_elements_',Vas.name);
      elseif ~isempty(Vfrom.name),
	sistr=sprintf('(%s)',list2str(disistr,'*'));
      else
	error 'Can not find out how to size argument'
      end	
    else
      sistr=sprintf('%d',si);
    end
    bytesstr=sprintf('sizeof(%s)',V.ctype);
    
    switch upper(style),
     case 'COPYARGSIN'      
      fline('@if( nrhs_IN>%d)',n-1);      
      fline('@    prhs[nrhs++]=(mxArray *)prhs_IN[%d];',n-1);
      if V.wsuse,
	fline('@else',n-1);
	fline('@    if(prhs[nrhs]=mexGetArray("%s","%s"))',V.name,V.wsname);
	fline('@        nrhs++;',n-1);
	fline('@    else');
	fline('@        break;');
      else
	fline('@else',n-1);
	fline('@   break;');
      end
      
     case 'COPYARGSRET'
      if n==1 & V.wsuse==0,
	fline('@if(1)');
      else
	fline('@if(nlhs_IN>%d)',n-1);
      end
      fline('@    plhs_IN[%d]=plhs[%d];',n-1,n-1);
      if V.wsuse,
	fline('@else{',n-1);
	fline('@    mxSetName(plhs[%d],"%s");',n-1,V.name)
	fline('@    mexPutArray(plhs[%d],"%s");',n-1,V.wsname);
	fline('@}');
      end
%      fline('@printf("copy arg return(%%d) :%s\\n",nlhs_IN);',V.name) %%DEBUG
      
     case 'DEC'
      if V.ret | V.byref,
	fline('@%s _def_%s_[]={%s};',V.ctype,V.name,list2str(V.defvalue,','));
	fline('@%s *_%s_=_def_%s_;',V.ctype,V.name,V.name);
      elseif V.in,
	fline('@const %s _def_%s_[]={%s};',V.ctype,V.name,list2str(V.defvalue,','));
	fline('@const %s *_%s_=_def_%s_;',V.ctype,V.name,V.name);
      end
      fline('@int    _%s_no_dims_ =%d;',V.name,length(disi));
      fline('@int const   *_%s_dims_    =ones_dims;',V.name);
      fline('@int    _%s_elements_=%d;',V.name,length(V.defvalue));
      fline
      
     case 'DECLOC'
      if si<=1024,
	fline('@%s         _%s_[%d];',V.ctype,V.name,si);
      else
	fline('@%s         *_%s_=mxMalloc(%s*sizeof(%s));',V.ctype,V.name,sistr,V.ctype); %% TODO: SPINLOOK!!
      end
      fline('@int        _%s_no_dims_ =%d;',V.name,length(disistr));
      if length(disistr)==0,
	fline('@const int  *_%s_dims_  =ones_dims;',V.name);
      else
	fline('@const int  _%s_dims_[]  ={%s};',V.name,list2str(disistr,','));
      end
      fline('@int        _%s_elements_=%s;',V.name,sistr);
      fline
      
     case 'GETDIMS_SHAPE',
      if V.shapearg==1,
	fline('@/* Get iterator dimensions from a "shape" argument */')
	fline('@if(nrhs>idx+%d){',n-1);
	fline('@    mxArray *shape_plhs[1]={ NULL };')
	fline('@    mexCallMATLAB(1,shape_plhs,1,(mxArray **)&prhs[idx+%d],"int32");',n-1);
	fline('@    if(shape_plhs[0]!=NULL){');
	fline('@        _iter_dims_=(int *)mxGetPr(shape_plhs[0]);');
	fline('@        _iter_no_dims_=mxGetNumberOfElements(shape_plhs[0]);');
	fline('@        {   int n;');
	fline('@            for(n=0,_iter_end=1;n<_iter_no_dims_;n++)')
	fline('@                _iter_end*= _iter_dims_[n];')
	fline('@        }')	
	fline('@    }')
	fline('@}');
	return;
      end
      
     case 'RESHAPE'
      if V.reshapearg==1,
	fline('@/* Get iterator dimensions from a "reshape" argument */')
	fline('@if(nrhs>idx+%d){',n-1);
	fline('@    mxArray *shape_plhs[1]={ NULL };')
	fline('@    mexCallMATLAB(1,shape_plhs,1,(mxArray **)&prhs[idx+%d],"int32");',n-1);
	fline('@    if(shape_plhs[0]!=NULL){');
	fline('@        rs_iter_dims_=(int *)mxGetPr(shape_plhs[0]);');
	fline('@        rs_iter_no_dims_=mxGetNumberOfElements(shape_plhs[0]);');
	fline('@        {   int n;');
	fline('@            for(n=0,rs_iter_end=1;n<rs_iter_no_dims_;n++)')
	fline('@                rs_iter_end*= rs_iter_dims_[n];')
	fline('@        }')	
	fline('@    }')
	fline('@    if(rs_iter_end!=_iter_end) mexErrMsgTxt("Reshape argument causing wrong number of new elements.");')
	fline('@}');
	return;
      end
      
     case 'GETDIMS'
      if V.iterdim==inf,
	fline('@/* If iterator dimensions not know, get it from first arguments shape/size */')
	fline('@if(nrhs>idx+%d && _iter_dims_==NULL){',n-1);
	fline('@    _iter_no_dims_=myGetNumberOfDimensions(prhs[idx+%d])-(%d);',n-1,length(disi));
	fline('@    _iter_dims_=mxGetDimensions(prhs[idx+%d]);',n-1);
	if V.lastdims,
	  fline('@    _iter_dims_=&_iter_dims_[%d];',length(disi));
	end
	if(si<inf)
	  fline('@    _iter_end= mxGetNumberOfElements(prhs[idx+%d])/(%d);',n-1,max(si,1) );
	else
	  fline('@    {   int n;');
	  fline('@        for(n=0,_iter_end=1;n<_iter_no_dims_;n++)')
	  fline('@            _iter_end*= _iter_dims_[n];');
	  fline('@    }')
	end
	fline( '@}');
	return;
      end

     case 'GETDIMS2'
      if V.iterdim(1)>0 & V.iterdim(end)<=6,
	fline('@if(nrhs>idx+%d){',n-1);
	fline('@    if(_iter_no_dims_<%d) ',V.iterdim(end));
	fline('@      _iter_no_dims_=%d;',V.iterdim(end));
	fline('@    {');	
	if length(V.iterdim)==1,
	  fline('@    _iter_make_dims[%d]=mxGetNumberOfElements(prhs[idx+%d]);',V.iterdim(1)-1,n-1)
	  fline('@        _iter_end*=_iter_make_dims[%d];',V.iterdim(1)-1)
	else  %% Not full supported yet at: 2002-05-31 V 1.0 Beta
	  if V.lastdims,
	    tr_offset=length(disi);
	  else
	    tr_offset=0;
	  end
	  fline('@        const int *di=mxGetDimensions(prhs[idx+%d]);',n-1);
	  fline('@        const int nodi=myGetNumberOfDimensions(prhs[idx+%d]);',n-1);
	  fline('@        int n;');
	  fline('@        for(n=0;n<nodi-%d && %d+n<6;n++){',length(disi),V.iterdim(1)-1)
	  fline('@            _iter_make_dims[%d+n]=di[n+%d];',V.iterdim(1)-1,tr_offset)
	  fline('@            _iter_end*=di[n+%d];',tr_offset)
	  fline('@        }')
	end
	fline('@    }')
	fline('@}')
      end      
     case 'GETARGS'
      fline( '@  ');
      fline( '@/* Get argument:  %s    */',V.name);
      txtarg=sprintf('as input argument \\"%s\\" (%d)',V.name,n);
      fline( '@if(nrhs<=idx) break; else no_arg_in=%d;',n);
      if V.byref,
	fline( '@{');
	fline( '@    const char *name=mxGetName(prhs[idx++]);');
	fline( '@    if(name[0]==0) mexErrMsgTxt("(Only) A variable name expected %s for reference variable.");',txtarg);
	fline( '@    {char buff[100];sprintf(buff,"%%s=%s(%%s);%%s(1)=%%s(1);",name,name,name,name);mexEvalString(buff);}',V.type);
	fline( '@    ptr=mexGetArrayPtr(name,"caller");');
	fline( '@}');
      else
	fline('@ptr=prhs[idx++];');
	if V.typecast,
	  fline('@if(mxGetClassID(ptr)!=mx%s_CLASS){',upper(V.type));
	  fline('@    mxArray *cast_plhs[1]={ NULL };',V.type,txtarg);
	  fline('@    mexCallMATLAB(1,cast_plhs,1,(mxArray **)&ptr,"%s");',V.type);
	  fline('@    ptr=cast_plhs[0];',V.type,txtarg);
	  fline('@}');
	end
      end      
      fline( '@if(mxGetClassID(ptr)!=mx%s_CLASS)',upper(V.type));
      fline( '@    _ERROR_FF_CALL("Datatype %s expected %s");',V.type,txtarg);
      fline('@_%s_ =(%s *)mxGetPr(ptr);',V.name,V.ctype);
      fline('@_%s_no_dims_=myGetNumberOfDimensions(ptr);',V.name);
      fline('@_%s_elements_=mxGetNumberOfElements(ptr);',V.name);
      fline('@_%s_dims_=mxGetDimensions(ptr);',V.name);
      if V.lastdims,
	fline('@_%s_dims_=&_%s_dims_[%d];',V.name,V.name,length(disi));
      end
      if V.iterdim>0,
	if V.iterdim<=6,
	  itersizestr=sprintf('_iter_dims_[%d]',V.iterdim-1); 
	else
	  itersizestr='_iter_end'; 
	end	
	% 
	fline('@/* Remove leading/trailing iterator dimensions */');
	fline('@{   int n=0,e=1;');
	fline('@    for(n=0; ;n++){');
%%	fline('@        mexPrintf("A: n=%%d e:%%d _%s_dims_[n]=%%d\\n",n,e,_%s_dims_[n]);',V.name,V.name);
	fline('@        if(e==%s && _%s_no_dims_-n==%d)',itersizestr,V.name,size(V.index,1));
	fline('@            break;');
	fline('@        if(n>=_%s_no_dims_ | e * _%s_dims_[n]>%s)',V.name,V.name,itersizestr);
	fline('@            _ERROR_FF_CALL("Can not match size of dimensions for %s to iterator");',V.name);
	fline('@        e *=_%s_dims_[n];',V.name);
%%	fline('@        mexPrintf("A: n=%%d e:%%d _%s_dims_[n]=%%d\\n",n,e,_%s_dims_[n]);',V.name,V.name);
	fline('@    }');
	fline('@    _%s_elements_/=e;',V.name);
	fline('@    _%s_no_dims_-=n;',V.name);
	fline('@    _%s_dims_=&_%s_dims_[n];',V.name,V.name);
	fline('@}');
      end
      if si==inf,
	%% TODO: check each dimension???
      else
	fline('@if( _%s_elements_!=%d )',V.name,si);
	fline('@    _ERROR_FF_CALL("Expected %d elements as iterator window dims %s");',si,txtarg);
      end      
     case 'RETARGS'
      fline( '@  ');
      fline( '@/* Create return argument:  %s */',V.name);
      if n==1,
	fline( '@no_arg_ret=%d;',n);
      else
	fline( '@if(nlhs<%d) break; else no_arg_ret=%d;',n,n);
      end
      if V.iterdim==0,
	if isempty(V.index),
	  fline('@{int di[]={1,1};plhs[%d]=mxCreateNumericArray(2,di,mx%s_CLASS,mxREAL);}',n-1,upper(V.type));
	else
	  fline('@{int di[]={%s};plhs[%d]=mxCreateNumericArray(%d,di,mx%s_CLASS,mxREAL);}',...
		list2str(disistr,','),n-1,length(disistr),upper(V.type));
	end
      else
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fline('@{');
	if V.iterdim<=6,	
	  fline('@    int di[1]={%d}; int ndi=%d;',V.iterdim-1,1);
	else
	  fline('@    int di[]= {%s}; int ndi=%d;',list2str([disistr,{'1'}],','),length(disistr));
	end
	if V.lastdims,
	  fline('@    plhs[%d]=mk_iterator_NumericArray(ndi,di,_iter_no_dims_,_iter_dims_,mx%s_CLASS);',n-1, upper(V.type));
	else
	  fline('@    plhs[%d]=mk_iterator_NumericArray(_iter_no_dims_,_iter_dims_,ndi,di,mx%s_CLASS);',n-1, upper(V.type));
	end
	fline('@}');
      end
      
      fline('@_%s_=(%s *)mxGetPr(plhs[%d]);',V.name,V.ctype,n-1);
      fline('@_%s_no_dims_=myGetNumberOfDimensions(plhs[%d]);',V.name,n-1);
      fline('@_%s_elements_=mxGetNumberOfElements(plhs[%d]);',V.name,n-1);
      fline('@_%s_dims_=mxGetDimensions(plhs[%d]);',V.name,n-1);
      if V.lastdims,
	fline('@_%s_dims_=&_%s_dims_[%d];',V.name,V.name,length(disi));
      end
      if V.iterdim>0,
	if V.iterdim<=6,
	  itersizestr=sprintf('_iter_dims_[%d]',V.iterdim-1); 
	else
	  itersizestr='_iter_end'; 
	end
	fline('@/* Remove leading/trailing iterator dimensions */');
	fline('@{   int n=0,e=1;');
	fline('@    for(n=0; ;n++){');
%%	fline('@        mexPrintf("A: n=%%d e:%%d _%s_dims_[n]=%%d\\n",n,e,_%s_dims_[n]);',V.name,V.name);
	fline('@        if(e==%s)',itersizestr);
	fline('@            break;');
	fline('@        if(n>=_%s_no_dims_ | e * _%s_dims_[n]>%s)',V.name,V.name,itersizestr);
	fline('@            _ERROR_FF_CALL("Can not match size of dimensions for %s to iterator");',V.name);
	fline('@        e *=_%s_dims_[n];',V.name);
%%	fline('@        mexPrintf("A: n=%%d e:%%d _%s_dims_[n]=%%d\\n",n,e,_%s_dims_[n]);',V.name,V.name);
	fline('@    }');
	fline('@    _%s_elements_/=e;',V.name);
	fline('@    _%s_no_dims_-=n;',V.name);
	fline('@    _%s_dims_=&_%s_dims_[n];',V.name,V.name);
	fline('@}');
      end
            
      %%% SET DEFAULT VALUES %%%
      if V.iterdim==0,
	if length(V.defvalue)==1 & si<1000, %% TODO: This can be better.....
	  V.defvalue(1:si)=V.defvalue(1);
	end
	if ~isempty(find(V.defvalue~=0)),
	  fline('@{%s def[]={%s};memcpy(_%s_,def,(%d)*sizeof(%s));}',...
		V.ctype,list2str(V.defvalue,','),V.name,length(V.defvalue),V.ctype);
	end
      end      
%      fline('printf("MK ret arg:%s\\n");',V.name) %%DEBUG
     
     case 'DEFINE'
      if V.iterdim==0,
	idxstr=sprintf('0');
      elseif V.iterdim(end)<=6,
	idxstr=sprintf('_iter_i%d%d',V.iterdim(1:min(2,end)));
      elseif V.iterdim(end)==inf,
	idxstr=sprintf('_iter_i');
      else
	error 'Non supported dimension number in declaration'
      end      
      if isempty(V.index),
	argstr='';
	subidxstr='';
      elseif size(V.index,1)==1,
	argstr='X';
	subidxstr=sprintf('INDEXERR((int)(X)-(%d),0,%s)',V.index(1,1),sistr);
      elseif size(V.index,1)==2,
	argstr='X,Y';
	subidxstr=sprintf('INDEXERR(((int)(X)-(%d))+ ((int)(Y)-(%d))*(%s),0,%s)',V.index(1:2,1),disistr{1},sistr);
      elseif size(V.index,1)==3,
	argstr='X,Y,Z';
	subidxstr=sprintf('INDEXERR(((int)(X)-(%d))+(((int)(Y)-(%d))+((int)(Z)-(%d))*(%s))*(%s),0,%s)',...
			  V.index(1:3,1),disistr{1:2},sistr);
      else
	error 'Non supported number of dimensions in subscript reference to variable,  Only 0 to 3 supported'
      end
      if length(subidxstr)>0,
	if V.lastdims,
	    idxstr=sprintf('%s*_%s_elements_',idxstr,V.name);
	else
	  if V.iterdim==inf,
	    subidxstr=[subidxstr '*_iter_end'];
	  elseif V.iterdim<=6 & V.iterdim>0,
	    subidxstr=[subidxstr sprintf('*size(iter,%d)',V.iterdim)];
	  end
	end
      end
            
      if ~isempty(argstr), argstr=['(' argstr ')']; end
      if ~isempty(subidxstr) idxstr=[idxstr '+' subidxstr]; end
      
      defstr=sprintf('#define %s%s _%s_[%s]',V.name,argstr,V.name,idxstr);
      fline(defstr);

     case {'DEFINE_NOIN', 'DEFINE_NORET'}      
      if isempty(V.index),
	  fline('#define %s _%s_[0]',V.name,V.name);
	else
	  if length(V.defvalue)==1,
	    fline('#define %s(...) _%s_[0]',V.name,V.name);
	  else
	    if size(V.index,1)==1,
	      fline('#define %s(X) _%s_[INDEXERR((X)-(%d),0,%d)]',V.name,V.name,V.index(1,1),length(V.defvalue));
	    elseif size(V.index,1)==2,
	      fline('#define %s(X,Y) _%s_[INDEXERR(((X)-(%d))+((Y)-(%d))*(%d),0,%d)]',V.name,V.name,...
		    V.index(1,1),V.index(2,1),disi(2),length(defvalue));
	    elseif size(V.index,1)==3,
	      fline('#define %s(X,Y,Z) _%s_[INDEXERR(((X)-(%d)) +((Y)-(%d))*(%d) +((Z)-(%d))*(%d)*(%d),0,%d)]',...
		    V.name,V.name, V.index(1,1),  V.index(2,1),disi(2),  V.index(3,1),disi(2:3),length(defvalue));
	    else
	      error 'To many dimentions for arguments with defualt value, Only 1 to 3 supported'
	    end
	  end
      end

     case 'UNDEFINE'
      fline('#undef %s',V.name);

     case 'TH_DEC'
      fline('@volatile %s  *_global_%s_;',        V.ctype,V.name);
      fline('@volatile const int *_global_%s_dims_;',   V.name);
      fline('@volatile int _global_%s_no_dims_;', V.name);
      fline('@volatile int _global_%s_elements_;', V.name);
      if (V.ret | V.byref) & V.iterdim~=inf,
	fline('@volatile %s *_global_return_%s_[%d];',V.ctype,V.name,DEF.CPU);
      end

     case 'TH_TO_GLOBAL'
      fline('@_global_%s_dims_=_%s_dims_;',V.name,V.name);
      fline('@_global_%s_no_dims_=_%s_no_dims_;',V.name,V.name);
      fline('@_global_%s_elements_=_%s_elements_;',V.name,V.name);
      if (V.ret | V.byref) & V.iterdim~=inf,
	fline('@{int n; for(n=1;n<global_nodes_total;n++) _global_return_%s_[n]=my_malloc_copy(_%s_,%s*%s,%d);}',...
	      V.name,V.name,bytesstr,sistr,V.byref+V.defvalue(1)~=0 );
      end
      fline('@_global_%s_=(%s *)_%s_;',V.name,V.ctype,V.name);
      fline

     case 'TH_FROM_GLOBAL'
      fline('@_%s_dims_=(const int *)_global_%s_dims_;',V.name,V.name);
      fline('@_%s_no_dims_=_global_%s_no_dims_;',V.name,V.name);
      fline('@_%s_elements_=_global_%s_elements_;',V.name,V.name);
      if (V.ret | V.byref) & V.iterdim~=inf,
	fline('@_%s_=(%s *)_global_return_%s_[node_id];',V.name,V.ctype,V.name);
      else
	fline('@_%s_=(%s *)_global_%s_;',V.name,V.ctype,V.name);
      end
      fline

     case 'TH_STOP_GLOBAL'
      if (V.ret | V.byref) & V.iterdim~=inf,
	fline('@{int n,e;');
	fline('@    for(n=1;n<global_nodes_total;n++)');
	fline('@        for(e=0;e<%s;e++)',sistr);
	if V.defvalue(1)==0,
	  fline('@            _%s_[e]+=_global_return_%s_[n][e];',V.name,V.name);
	else
	  fline('@            _%s_[e]*=_global_return_%s_[n][e];',V.name,V.name);
	end
	fline('@}');
      end

     otherwise
      error 'Iternal error, unknow style parameter'
    end
  end
  return;  

%===================================================================  
%===================================================================  

function print_insert_cpu(DEF,part)
  if DEF.CPU<2,
    return;
  end
  fline
  fline( '/* /////////////////// MULTI CPU SUPPORT SECTION \\\\\\\\\\\\\\\\\\\ */' )
  switch upper(part),
   case 'INCLUDE',
    fline( '#include <pthread.h>')
    fline( '#include <signal.h>')
    
   case 'GLOBAL',
    fline('pthread_t     thread[%d];',DEF.CPU);
    fline( 'volatile int           global_nodes_total=1;')
    fline( 'volatile int  global_iter_start=0;')
    fline( 'volatile int  global_iter_end=0;')
    fline( 'volatile const int  *global_iter_dims_;')
    fline( 'volatile int  global_iter_no_dims_;')
    fline( 'volatile int  global_no_arg_in=0;')
    fline( 'volatile int  global_no_arg_ret=0;')
    fline( 'volatile void (*global_matlab_signal_handler)(int)=NULL;')
    fline( 'volatile int  global_interupt_counter=0;')
    fline
    fline( 'int signal_handler_function(int sig);')
    fline( 'void start_threads();')
    fline( 'void wait_threads();')
    fline( 'void kill_threads();')
    fline
    fline( '/* Global variables for argument passing between mother and threads */')
    print_variable(DEF,'TH_DEC','INRET');
    fline 
    fline( '/* Thread processes start function */'     )
    fline( 'int thread_function(void *arg)')
    fline( '{')
    fline( '    int node_id=(int)arg;')
    fline( '    mexFunction( -node_id, NULL,0,NULL); /* "Durty trick" for for thread to enter into calculation function.*/')
    fline( '    pthread_exit(0);')
    fline( '}')
    fline
    fline( 'int signal_handler_function(int sig)')
    fline( '{')
    fline( '    if(pthread_self()==thread[0])')
    fline( '    {')
    fline( '        signal(SIGINT,(void *)signal_handler_function); /* Needed?? */')
    fline( '        global_interupt_counter++;')
    fline( '        if(global_interupt_counter==1)')
    fline( '        {')
    fline( '            void (*matlab_signal_handler)(int)=(void *)global_matlab_signal_handler;  /* Store function pointer */')
    fline( '            mexPrintf("\nIterator Interupted, waiting for threads to finish...");')
    fline( '            wait_threads();')
    fline( '            mexPrintf("  done!\n");')
    fline( '            matlab_signal_handler(sig); ')
    fline( '        }'    )
    fline( '        mexPrintf("Okey, I will try to kill the threads...\n");')
    fline( '        kill_threads();')
    fline( '        return 0;')
    fline( '    }')
    fline( '    pthread_exit(0);')
    fline( '    return 0;')
    fline( '}')
    fline
    fline( 'void start_threads()')
    fline( '{')
    fline( '    int n;')
    fline( '    global_interupt_counter=0;')
    fline( '    if(global_matlab_signal_handler==NULL)')
    fline( '        global_matlab_signal_handler=(void *)signal(SIGINT,(void *)signal_handler_function);')
    fline( '    else')
    fline( '        signal(SIGINT,(void *)signal_handler_function); /* TODO: TA BORT ?????? */ ')
    fline( '    thread[0]=pthread_self();')
    fline( '    for(n=1;n<global_nodes_total;n++)')
    fline( '        pthread_create(&thread[n],0,(void *)thread_function,(void *)(n) );')
    fline( '}')
    fline
    fline( 'void wait_threads()')
    fline( '{')
    fline( '    int n;')
    fline( '    for(n=1;n<global_nodes_total;n++)')
    fline( '        pthread_join(thread[n],NULL);')
    fline( '    if(global_matlab_signal_handler)')
    fline( '        signal(SIGINT,(void *)global_matlab_signal_handler);')
    fline( '    global_matlab_signal_handler=NULL;')
    fline( '}')
    fline
    fline( 'void kill_threads()')
    fline( '{')
    fline( '    int n;')
    fline( '    for(n=1;n<global_nodes_total;n++)')
    fline( '        pthread_kill(thread[n],SIGINT);')
    fline( '}')
    fline
    fline( 'void *my_malloc_copy(void *ptr,int bytes,int copyflag)')
    fline( '{')
    fline( '    void *ret=(void *)mxCalloc(1,bytes);')
    fline( '    if(ret==NULL) mexErrMsgTxt("Internal out of memory");')
    fline( '    if(copyflag) memcpy(ret,ptr,bytes);')
    fline( '    return ret;')
    fline( '}')
    fline
    
   case 'LOCAL',
    fline( '     int        node_id=0;            /* Variable telling about calc node number, first thread = 1 */')
    
   case 'SKIPSTART',
    fline( '     if(nlhs_IN<0)                       /* Is this a starting thread? */')
    fline( '         node_id=-nlhs_IN;               /* Get node_id for this thread */')
    fline
    fline( '     if(node_id==0)                  /* If not a thread then run Init section */')
    
   case 'START',
    fline( '   if(node_id==0){')
    fline( '       if(_iter_end>=%d)',DEF.MULTI_CPU_MINSIZE)
    fline( '           global_nodes_total=%d;',DEF.CPU)
    fline( '        else')
    fline( '            global_nodes_total=1;')
    fline( '   }')
    fline
    fline( '    if(global_nodes_total>1) /* start as thread ?*/')
    fline( '    {')
    fline( '/* Mother section */')
    fline( '        if(node_id==0){'    )
    fline( '            '    )
    fline( '            /* Pass Local Variables via Global Variables */')
    fline( '            global_iter_end=_iter_end;')
    fline( '            global_iter_dims_=_iter_dims_;')
    fline( '            global_iter_no_dims_=_iter_no_dims_;')

    print_variable(DEF,'TH_TO_GLOBAL','INRET');
    
    fline( '            global_no_arg_in= no_arg_in;')
    fline( '            global_no_arg_ret=no_arg_ret;')
    fline( '            start_threads();   /* CREATE THE THREADS */')
    fline( '        } ')
    fline( '/* Thread section */')
    fline( '        else{'        )
    fline( '            /* Get Local Variables from Global Variables */')
    fline( '            no_arg_in =global_no_arg_in;')
    fline( '            no_arg_ret=global_no_arg_ret;')
    fline( '            _iter_dims_=(int *)global_iter_dims_;')
    fline( '            _iter_no_dims_=global_iter_no_dims_;')
   
    print_variable(DEF,'TH_FROM_GLOBAL','INRET');

    fline( '        }')
    fline( '        _iter_end=global_iter_end;')
    fline( '        _iter_start=node_id*(global_iter_end/global_nodes_total);')
    fline( '        if(node_id==global_nodes_total-1)')
    fline( '            _iter_stop=global_iter_end;')
    fline( '        else')
    fline( '            _iter_stop= (node_id+1)*(global_iter_end/global_nodes_total);')
    fline( '    }')
   
   case 'STOP',
    fline( '    if(global_nodes_total>1) /* Stop as thread*/')
    fline( '    {'    )
    fline( '        /* Reduction of threads, and overlaping return data */'    )
    fline( '        if(node_id!=0)'    )
    fline( '        {'    )
    fline( '            return;'    )
    fline( '        }')
    fline( '        else')
    fline( '        {')
    fline( '            int n;')
    fline( '            wait_threads();')

    print_variable(DEF,'TH_STOP_GLOBAL','IN');

    fline( '        }'    )
    fline( '    }' )
  end
  fline( '/* \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\    ////////////////////////////// */')
  fline
  return;
  
  
 % #define V3_M3xV3(vr,s,v) vr[0]=s*v[]
